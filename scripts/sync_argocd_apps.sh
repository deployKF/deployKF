#!/usr/bin/env bash

set -euo pipefail

#
# This script automatically syncs the ArgoCD applications that make up deployKF.
#

#######################################
# CONFIGURATION
#######################################

# the argocd application name prefix
#  - Must have the same value as the `argocd.appNamePrefix` deployKF value.
#    Used when multiple deployKF instances are managed with a single argocd server.
ARGOCD_APP_NAME_PREFIX="${ARGOCD_APP_NAME_PREFIX:-}"

# the namespace where argocd is installed
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

# the argocd server URL
#  - If empty, port-forwarding will be used to connect to the argocd server.
ARGOCD_SERVER_URL="${ARGOCD_SERVER_URL:-}"

# credentials for argocd
#  - If password is empty, and username is "admin", the 'argocd-initial-admin-secret' will be read from the cluster.
#    This will NOT work if you have changed the ArgoCD admin password.
ARGOCD_USERNAME="${ARGOCD_USERNAME:-admin}"
ARGOCD_PASSWORD="${ARGOCD_PASSWORD:-}"

# how to handle resources that require PRUNING (deletion)
#  - 'always': always PRUNE resources without prompting
#  - 'prompt': for each application that requires pruning, prompt the user to confirm
#  - 'ask': prompt the user to choose a mode
ARGOCD_PRUNE_MODE="${ARGOCD_PRUNE_MODE:-ask}"
ARGOCD_PRUNE_MODE=$(echo "$ARGOCD_PRUNE_MODE" | tr '[:upper:]' '[:lower:]')

# timeouts for argocd commands
ARGOCD_SYNC_TIMEOUT_SECONDS="${ARGOCD_SYNC_TIMEOUT_SECONDS:-600}"
ARGOCD_WAIT_TIMEOUT_SECONDS="${ARGOCD_WAIT_TIMEOUT_SECONDS:-300}"

#######################################
# REQUIREMENTS
#######################################

# ensure bash version 4.4+
if [[ ${BASH_VERSINFO[0]} -lt 4 || (${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 4) ]]; then
  echo ">>> ERROR: Bash version 4.4+ is required to run this script, current version: '${BASH_VERSION}'"
  exit 1
fi

# ensure 'argocd' is installed
if [[ -z "$(command -v argocd)" ]]; then
  echo ">>> ERROR: 'argocd' must be installed to run this script"
  exit 1
fi

# ensure 'jq' is installed
if [[ -z "$(command -v jq)" ]]; then
  echo ">>> ERROR: 'jq' must be installed to run this script"
  exit 1
fi

# ensure 'kubectl' is installed
if [[ -z "$(command -v kubectl)" ]]; then
  echo ">>> ERROR: 'kubectl' must be installed to run this script"
  exit 1
fi

#######################################
# COLORS
#######################################

# if color is supported, use it
if [[ -t 1 ]] && [[ -n "$(command -v tput)" ]] && [[ $(tput colors) -ge 8 ]]; then
  COLOR_RED=$(tput setaf 1)
  COLOR_GREEN=$(tput setaf 2)
  COLOR_YELLOW=$(tput setaf 3)
  COLOR_BLUE=$(tput setaf 4)
  COLOR_MAGENTA=$(tput setaf 5)
  BOLD=$(tput bold)
  UL_S=$(tput smul)
  UL_E=$(tput rmul)
  NC=$(tput sgr0)
else
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_MAGENTA=""
  BOLD=""
  UL_S=""
  UL_E=""
  NC=""
fi

function echo_red() {
  echo "${COLOR_RED}${BOLD}$1${NC}"
}

function echo_green() {
  echo "${COLOR_GREEN}${BOLD}$1${NC}"
}

function echo_yellow() {
  echo "${COLOR_YELLOW}${BOLD}$1${NC}"
}

function echo_blue() {
  echo "${COLOR_BLUE}${BOLD}$1${NC}"
}

function echo_magenta() {
  echo "${COLOR_MAGENTA}${BOLD}$1${NC}"
}

#######################################
# FUNCTIONS
#######################################

# authenticate to argocd
function argocd_login() {
  local _argocd_server_url="$1"
  local _argocd_namespace="$2"
  local _argocd_username="$3"
  local _argocd_password="$4"

  # if "admin" is the username and no password is provided, get the password from the cluster
  if [[ "$_argocd_username" == "admin" && -z "$_argocd_password" ]]; then
    echo ""
    echo_blue "=========================================================================================="
    echo_blue "Getting ArgoCD admin password..."
    echo_blue "------------------------------------------------------------------------------------------"
    echo_blue "Namespace: '$_argocd_namespace'"
    echo_blue "Secret Name: 'argocd-initial-admin-secret'"
    echo_blue "=========================================================================================="
    _argocd_password=$(
      kubectl -n "$_argocd_namespace" get secret "argocd-initial-admin-secret" -o jsonpath="{.data.password}" \
      | base64 -d
    )
    echo_green ">>> DONE"
  fi

  # log in to argocd
  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Authenticating with ArgoCD..."
  echo_blue "------------------------------------------------------------------------------------------"
  echo_blue "Server: ${_argocd_server_url:-<port-forward>}"
  echo_blue "Namespace: '$_argocd_namespace'"
  echo_blue "Username: '$_argocd_username'"
  echo_blue "Password: '**********'"
  echo_blue "=========================================================================================="
  if [[ -n "$_argocd_server_url" ]]; then
    argocd login "$_argocd_server_url" --username "$_argocd_username" --password "$_argocd_password"
  else
    # NOTE: we must export ARGOCD_OPTS for all the argocd commands to see it
    export ARGOCD_OPTS="--port-forward --port-forward-namespace '$_argocd_namespace'"
    argocd login --username "$_argocd_username" --password "$_argocd_password"
  fi
  echo_green ">>> DONE"
}

# syncs a list of argocd applications
#  - if pruning is disabled, the user may be prompted to retry with pruning enabled
function sync_argocd_apps() {
  local _enable_prune="$1"
  local _prompt_for_prune="$2"
  local _force_sync="$3"
  local _resource_selectors="$4"
  local _app_names=("${@:5}")

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Syncing ArgoCD applications..."
  echo_blue "------------------------------------------------------------------------------------------"
  echo_blue "Applications:"
  local _app_name
  for _app_name in "${_app_names[@]}"; do
    echo_blue " - $_app_name"
  done
  if [[ -n "$_resource_selectors" ]]; then
    echo_blue "Resource Selectors:"
    local _resource_selector
    for _resource_selector in $_resource_selectors; do
      echo_blue " - $_resource_selector"
    done
  fi
  echo_blue "Pruning: $_enable_prune"
  echo_blue "Force Sync: $_force_sync"
  echo_blue "Timeout Seconds: $ARGOCD_SYNC_TIMEOUT_SECONDS"
  echo_blue "=========================================================================================="

  # build sync command arguments
  local -a _sync_args=()
  _sync_args+=(
    "--timeout" "$ARGOCD_SYNC_TIMEOUT_SECONDS"
  )
  if [[ "$_force_sync" == "true" ]]; then
    _sync_args+=("--force")
  fi
  if [[ "$_enable_prune" == "true" ]]; then
    _sync_args+=("--prune")
  fi

  # add resource selectors to the sync command
  local _resource_selector
  for _resource_selector in $_resource_selectors; do
    _sync_args+=("--resource" "$_resource_selector")
  done

  # run the sync command
  #  - captures STDERR
  #  - prints both STDERR and STDOUT to the console
  local _cmd_stderr
  local _cmd_exit_code
  exec 3>&1
  set +e
  _cmd_stderr=$(argocd app sync "${_app_names[@]}" "${_sync_args[@]}" 2>&1 >&3 | tee /dev/stderr)
  _cmd_exit_code=$?
  set -e
  exec 3>&-

  # if the command failed, handle the error
  if [[ $_cmd_exit_code -ne 0 ]]; then

    # handle pruning errors
    # NOTE: argocd will exit non-zero if pruning is required
    if [[ "$_cmd_stderr" =~ "resources require pruning" ]]; then
      echo_yellow ">>> WARNING: There are resources that need to be PRUNED"
      if [[ "$_prompt_for_prune" == "true" ]]; then
        ask_sync_again_with_prune "$_resource_selectors" "${_app_names[@]}"
      else
        echo_yellow ">>> Continuing without pruning..."
      fi

    # otherwise, exit with the error code
    else
      echo_red ">>> ERROR: Sync Failed"
      exit $_cmd_exit_code
    fi
  else
    echo_green ">>> Sync Succeeded"
  fi
}

# ask the user to sync again with pruning enabled
function ask_sync_again_with_prune() {
  local _resource_selectors="$1"
  local _app_names=("${@:2}")

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Prompting to sync again with PRUNING enabled..."
  echo_blue "------------------------------------------------------------------------------------------"
  echo_blue "Applications:"
  local _app_name
  local _apps_include__apps_of_apps="false"
  local _apps_include__profile_generator="false"
  for _app_name in "${_app_names[@]}"; do
    echo_blue " - $_app_name"
    # NOTE: some apps have special TIPS which we will show to the user
    if [[ "$_app_name" =~ "deploykf-app-of-apps" ]]; then
      _apps_include__apps_of_apps="true"
    elif [[ "$_app_name" =~ "deploykf-profiles-generator" ]]; then
      _apps_include__profile_generator="true"
    fi
  done
  if [[ -n "$_resource_selectors" ]]; then
    echo_blue "Resource Selectors:"
    local _resource_selector
    for _resource_selector in $_resource_selectors; do
      echo_blue " - $_resource_selector"
    done
  fi
  echo_blue "=========================================================================================="
  echo ""
  echo_red ">>> WARNING: the previous sync failed because some resources require PRUNING (deletion)."
  echo ""
  echo_yellow ">>> NOTES:"
  echo_yellow ">>>  - review the above resources which say '(requires pruning)'"
  echo_yellow ">>>    alternatively, review the application(s) in the ArgoCD UI"
  echo_yellow ">>>  - ArgoCD incorrectly lists some resources as needing to be pruned"
  echo_yellow ">>>    https://github.com/argoproj/argo-cd/issues/17188"
  echo ""
  if [[ "$_apps_include__apps_of_apps" == "true" ]]; then
    echo_blue ">>> TIPS: 'deploykf-app-of-apps'"
    echo_blue ">>>  - component Namespaces are never actually pruned"
    echo_blue ">>>    you must manually delete these Namespaces to avoid future prune errors"
    echo ""
  fi
  if [[ "$_apps_include__profile_generator" == "true" ]]; then
    echo_blue ">>> TIPS: 'deploykf-profiles-generator'"
    echo_blue ">>>  - carefully review any Profile resources that say '(requires pruning)'"
    echo_blue ">>>    removing a Profile resource will delete the associated Namespace"
    echo ""
  fi

  # prompt the user to sync again with pruning enabled
  while true; do
      echo "${COLOR_MAGENTA}${BOLD}Run sync again with PRUNING enabled? ${NC}(${BOLD}${UL_S}Y${UL_E}ES${NC} continue / ${BOLD}${UL_S}N${UL_E}O${NC} fail)${NC}"
      read -r -p "${COLOR_MAGENTA}${BOLD}RESPONSE:${NC} " response || echo "<no response>"
      case $(echo "$response" | tr '[:upper:]' '[:lower:]') in
          "yes" | "y" )
            echo_yellow ">>> Syncing again with pruning enabled..."
            sync_argocd_apps "true" "false" "false" "$_resource_selectors" "${_app_names[@]}"
            break
            ;;
          "no" | "n" )
            echo_red ">>> ERROR: Sync Failed, pruning required"
            exit 1
            ;;
          * )
            echo ""
            ;;
      esac
  done
}

# wait for an argocd application to be healthy
function argocd_app_wait() {
  local _app_names=("$@")

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Waiting for ArgoCD applications to be healthy..."
  echo_blue "------------------------------------------------------------------------------------------"
  echo_blue "Applications:"
  local _app_name
  for _app_name in "${_app_names[@]}"; do
    echo_blue " - $_app_name"
  done
  echo_blue "Timeout Seconds: $ARGOCD_WAIT_TIMEOUT_SECONDS"
  echo_blue "=========================================================================================="

  # wait for the application to be healthy
  argocd app wait "${_app_names[@]}" --health --timeout "$ARGOCD_WAIT_TIMEOUT_SECONDS"
  echo_green ">>> DONE"
}

# sync argocd applications that match a label selector
#  - applications are synced in parallel groups, based on their "sync wave"
#  - after each group is synced, we wait for all applications in that group to be healthy
function sync_argocd() {
  local _app_namespace="$1"
  local _app_selector="$2"
  local _fail_if_missing="$3"

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Getting status of ArgoCD applications..."
  echo_blue "------------------------------------------------------------------------------------------"
  echo_blue "Namespace: '$_app_namespace'"
  echo_blue "Application Selector:"
  echo_blue " - $_app_selector"
  echo_blue "=========================================================================================="

  # find all applications that match the selector
  local -a _app_names=()
  read -r -a _app_names <<< "$(argocd app list -l "$_app_selector" -N "$_app_namespace" -o "name" | tr '\n' ' ')"

  # if no applications are found, fail if required
  if [[ ${#_app_names[@]} -eq 0 ]]; then
    if [[ "$_fail_if_missing" == "true" ]]; then
      echo_red ">>> ERROR: No applications found matching the selector"
      exit 1
    else
      echo_yellow ">>> WARNING: No applications found matching the selector"
      return
    fi
  fi

  # this associative array has "sync wave numbers" as keys, and SPACE-separated "app names" as values
  local -A _sync_waves=()

  # this associative array has "app names" as keys, and "sync status" as values
  local -A _app_sync_statuses=()

  # this associative array has "app names" as keys, and "last operation phase" as values
  local -A _app_last_operation_phases=()

  # this associative array has "app names" as keys, and SPACE-separated "argocd resource selectors" as values
  #  - the format of each resource selector is: "<GROUP>:<KIND>:<NAMESPACE>/<NAME>" or "<GROUP>:<KIND>:<NAME>"
  local -A _app_force_sync_resources=()

  # build an array of applications to sync
  local _app_name
  local _app_json
  local _app_sync_wave
  local _app_sync_status
  local _app_operation_state
  local _app_operation_state_phase
  local _app_resources
  for _app_name in "${_app_names[@]}"; do

    # get the application as JSON (and refresh at same time)
    _app_json=$(argocd app get "$_app_name" -o json --refresh)

    # extract the sync-wave from the application (default: 0)
    _app_sync_wave=$(echo "$_app_json" | jq -r '.metadata.annotations."argocd.argoproj.io/sync-wave" // "0"')

    # extract the sync status from the application (default: "Unknown")
    # SPEC: https://github.com/argoproj/argo-cd/blob/v2.7.14/pkg/apis/application/v1alpha1/types.go#L1332-L1343
    _app_sync_status=$(echo "$_app_json" | jq -r '.status.sync.status // "Unknown"')

    # extract the operation state from the application (default: empty)
    # SPEC: https://github.com/argoproj/argo-cd/blob/v2.7.14/pkg/apis/application/v1alpha1/types.go#L1011-L1026
    _app_operation_state=$(echo "$_app_json" | jq -r '.status.operationState // empty')

    # extract the operation state phase from the application (default: "Succeeded")
    # SPEC: https://github.com/argoproj/gitops-engine/blob/v0.7.3/pkg/sync/common/types.go#L50-L58
    _app_operation_state_phase=$(echo "$_app_operation_state" | jq -r '.phase // "Succeeded"')

    # extract the list of resources managed by this application
    # SPEC: https://github.com/argoproj/argo-cd/blob/v2.7.14/pkg/apis/application/v1alpha1/types.go#L1566-L1579
    _app_resources=$(echo "$_app_json" | jq -c '.status.resources[]?')

    # build an array of resource selectors that require a forced sync
    # TODO: remove force-sync once ArgoCD has a way to force-sync individual resources
    #       https://github.com/argoproj/gitops-engine/issues/414
    local _app_resource
    local _app_resource_group
    local _app_resource_kind
    local _app_resource_name
    local _app_resource_namespace
    local _app_resource_status
    local _app_resource_health
    local _app_resource_health_status
    local _app_resource_requiresPruning
    local _app_resource_selector
    local _app_resource_force_sync
    IFS=$'\n'
    for _app_resource in $_app_resources; do
      _app_resource_group=$(echo "$_app_resource" | jq -r '.group // empty')
      _app_resource_kind=$(echo "$_app_resource" | jq -r '.kind // empty')
      _app_resource_name=$(echo "$_app_resource" | jq -r '.name // empty')
      _app_resource_namespace=$(echo "$_app_resource" | jq -r '.namespace // empty')
      _app_resource_status=$(echo "$_app_resource" | jq -r '.status // "Unknown"')
      _app_resource_health=$(echo "$_app_resource" | jq -r '.health // empty')
      _app_resource_health_status=$(echo "$_app_resource_health" | jq -r '.status // "Unknown"')
      _app_resource_requiresPruning=$(echo "$_app_resource" | jq -r '.requiresPruning // false')

      # construct a resource selector (for argocd commands)
      if [[ -n "$_app_resource_namespace" ]]; then
        _app_resource_selector="$_app_resource_group:$_app_resource_kind:$_app_resource_namespace/$_app_resource_name"
      else
        _app_resource_selector="$_app_resource_group:$_app_resource_kind:$_app_resource_name"
      fi

      # check if the resource requires forced sync
      #  - force sync is only relevant to resources that are not Synced, do not require pruning, and are not Missing
      if [[ "$_app_resource_status" != "Synced" &&
            "$_app_resource_requiresPruning" == "false" &&
            "$_app_resource_health_status" != "Missing"
      ]]; then
        _app_resource_force_sync="false"

        # kyverno ClusterPolicies with "generate" type rules cant be updated without a forced sync
        #  - https://github.com/kyverno/kyverno/issues/7718
        #  - in deployKF, all such policies have names containing "clone" or "generate"
        if [[ "$_app_resource_group" == "kyverno.io" &&
              "$_app_resource_kind" == "ClusterPolicy" &&
              ("$_app_resource_name" =~ "clone" || "$_app_resource_name" =~ "generate")
        ]]; then
          _app_resource_force_sync="true"
        fi

        # if the resource requires forced sync, add it to the array
        if [[ "$_app_resource_force_sync" == "true" ]]; then
          if [[ -v _app_force_sync_resources["$_app_name"] ]]; then
            _app_force_sync_resources[$_app_name]+=" $_app_resource_selector"
          else
            _app_force_sync_resources[$_app_name]="$_app_resource_selector"
          fi
        fi
      fi
    done
    unset IFS

    # if the sync status is "Unknown", fail
    if [[ "$_app_sync_status" == "Unknown" ]]; then
      echo_red ">>> ERROR: '$_app_name' has a sync status of 'Unknown'"
      exit 1
    fi

    # if the operation state phase is "Running" or "Terminating", fail
    if [[ "$_app_operation_state_phase" == "Running" || "$_app_operation_state_phase" == "Terminating" ]]; then
      echo_red ">>> ERROR: '$_app_name' has an operation in progress (phase: '$_app_operation_state_phase')"
      exit 1
    fi

    # add the application to the sync status array
    _app_sync_statuses[$_app_name]="$_app_sync_status"

    # add the application to the last operation phase array
    _app_last_operation_phases[$_app_name]="$_app_operation_state_phase"

    # add the application to the sync wave array
    if [[ -v _sync_waves["$_app_sync_wave"] ]]; then
      _sync_waves[$_app_sync_wave]+=" $_app_name"
    else
      _sync_waves[$_app_sync_wave]="$_app_name"
    fi
  done

  # get the sync waves in ascending order
  local _sync_wave
  local -a _sync_waves_sorted=()
  for _sync_wave in $(echo "${!_sync_waves[@]}" | tr ' ' '\n' | sort -n); do
    _sync_waves_sorted+=("$_sync_wave")
  done

  # print the sync waves and their applications
  echo_yellow ">>> Found ${#_app_sync_statuses[@]} applications in ${#_sync_waves_sorted[@]} sync waves."
  local _app_name
  local _sync_wave
  local _sync_wave_apps
  for _sync_wave in "${_sync_waves_sorted[@]}"; do
    IFS=' ' read -r -a _sync_wave_apps <<< "${_sync_waves[$_sync_wave]}"
    echo ""
    echo_yellow ">>> Sync wave $_sync_wave:"
    for _app_name in "${_sync_wave_apps[@]}"; do
      echo_yellow ">>>  - $_app_name (sync status: ${_app_sync_statuses[$_app_name]}) (last operation: ${_app_last_operation_phases[$_app_name]})"
    done
  done

  # sync out-of-sync applications in each sync wave
  local _app_name
  local _sync_wave
  local _sync_wave_apps
  for _sync_wave in "${_sync_waves_sorted[@]}"; do
    IFS=' ' read -r -a _sync_wave_apps <<< "${_sync_waves[$_sync_wave]}"

    # build an array of applications which require syncing in this wave
    local -a _require_sync_apps=()
    for _app_name in "${_sync_wave_apps[@]}"; do
      # if the application is not synced, or the last operation did not succeed, add it to the list
      if [[ "${_app_sync_statuses[$_app_name]}" != "Synced" || "${_app_last_operation_phases[$_app_name]}" != "Succeeded" ]]; then
        _require_sync_apps+=("$_app_name")
      fi
    done

    # if there are applications to sync, do it
    if [[ -n "${_require_sync_apps[*]}" ]]; then

      # force-sync specific resources for each application
      local _force_resource_array_str
      local _resource_str
      if [[ ${#_app_force_sync_resources[@]} -gt 0 ]]; then
        for _app_name in "${_require_sync_apps[@]}"; do
          if [[ -v _app_force_sync_resources["$_app_name"] ]]; then
            _force_resource_array_str="${_app_force_sync_resources[$_app_name]}"
            echo ""
            echo_yellow ">>> Force syncing specific resources from '$_app_name':"
            for _resource_str in $_force_resource_array_str; do
              echo_yellow ">>>  - $_resource_str"
            done
            sync_argocd_apps "false" "false" "true" "$_force_resource_array_str" "$_app_name"
          fi
        done
      fi

      # sync the applications
      case "$ARGOCD_PRUNE_MODE" in
        "always")
          sync_argocd_apps "true" "false" "false" "" "${_require_sync_apps[@]}"
          ;;
        "prompt")
          sync_argocd_apps "false" "true" "false" "" "${_require_sync_apps[@]}"
          ;;
        *)
          echo_red ">>> ERROR: Invalid ARGOCD_PRUNE_MODE: '$ARGOCD_PRUNE_MODE'"
          exit 1
          ;;
      esac
    fi

    # wait for ALL applications in this sync wave to be healthy
    # NOTE: this includes applications that were already in-sync before the sync command
    if [[ -n "${_sync_wave_apps[*]}" ]]; then
      argocd_app_wait "${_sync_wave_apps[@]}"
    fi
  done
}

# ask the user to set a prune mode
function ask_prune_mode() {
  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Prompting for PRUNE MODE..."
  echo_blue "=========================================================================================="
  echo_yellow ">>> Sometimes resources need to be ${COLOR_RED}PRUNED${COLOR_YELLOW} (deleted) as part of a sync."
  echo_yellow ">>> The PRUNE MODE determines how we handle these situations."
  echo_yellow ">>> (TIP: avoid this prompt by setting a default ${BOLD}ARGOCD_PRUNE_MODE${NC}${COLOR_YELLOW})"
  echo ""
  while true; do
    echo "${COLOR_MAGENTA}${BOLD}Which PRUNE MODE should we use? ${NC}(${BOLD}${UL_S}A${UL_E}LWAYS${NC} prune / ${BOLD}${UL_S}P${UL_E}ROMPT${NC} for each)"
    read -r -p "${COLOR_MAGENTA}${BOLD}RESPONSE:${NC} " response || echo "<no response>"
    case $(echo "$response" | tr '[:upper:]' '[:lower:]') in
       "always" | "a" )
          ARGOCD_PRUNE_MODE="always"
          break
          ;;
        "prompt" | "p" )
          ARGOCD_PRUNE_MODE="prompt"
          break
          ;;
        * )
          echo ""
          ;;
    esac
  done
}

#######################################
# MAIN
#######################################

# construct the base app selector for deployKF
ARGOCD_APP_SELECTOR="app.kubernetes.io/part-of=${ARGOCD_APP_NAME_PREFIX}deploykf"

# authenticate to argocd
argocd_login "$ARGOCD_SERVER_URL" "$ARGOCD_NAMESPACE" "$ARGOCD_USERNAME" "$ARGOCD_PASSWORD"

# ask the user to set a prune mode
if [[ "$ARGOCD_PRUNE_MODE" == "ask" ]]; then
  ask_prune_mode
fi

# sync the "deploykf-app-of-apps" application
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/name=deploykf-app-of-apps" "true"

# sync the "deploykf-namespaces" application
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/name=deploykf-namespaces" "false"

# sync all applications in the "deploykf-dependencies" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=deploykf-dependencies" "false"

# sync all applications in the "deploykf-core" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=deploykf-core" "false"

# sync all applications in the "deploykf-opt" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=deploykf-opt" "false"

# sync all applications in the "deploykf-tools" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=deploykf-tools" "false"

# sync all applications in the "kubeflow-dependencies" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=kubeflow-dependencies" "false"

# sync all applications in the "kubeflow-tools" group
sync_argocd "$ARGOCD_NAMESPACE" "${ARGOCD_APP_SELECTOR},app.kubernetes.io/component=kubeflow-tools" "false"