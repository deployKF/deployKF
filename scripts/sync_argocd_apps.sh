#!/usr/bin/env bash

set -euo pipefail

#
# This script automatically syncs the ArgoCD applications that make up deployKF.
#

#######################################
# CONFIGURATION
#######################################

# the namespace where argocd is installed
ARGOCD_NAMESPACE="argocd"

# the argocd server URL
#  - If empty, port-forwarding will be used to connect to the argocd server.
ARGOCD_SERVER_URL=""

# credentials for argocd
#  - If password is empty, and username is "admin", the 'argocd-initial-admin-secret' will be read from the cluster.
#    This will NOT work if you have changed the ArgoCD admin password.
ARGOCD_USERNAME="admin"
ARGOCD_PASSWORD=""

# how to handle resources that require pruning
#  - 'always': prune resources without prompting (DANGER: this can delete resources that are still in use)
#  - 'prompt': ask the user if they want to prune resources (defaults to 'no' after timeout)
#  - 'skip': continue silently without pruning
ARGOCD_PRUNE_MODE="prompt"
ARGOCD_PRUNE_PROMPT_SECONDS="30"

# timeouts for argocd commands
ARGOCD_SYNC_TIMEOUT_SECONDS="600"
ARGOCD_WAIT_TIMEOUT_SECONDS="300"

#######################################
# REQUIREMENTS
#######################################

# ensure bash version 4.2+
if [[ ${BASH_VERSINFO[0]} -lt 4 || (${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 2) ]]; then
  echo ">>> ERROR: Bash version 4.2+ is required to run this script, current version: '${BASH_VERSION}'"
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
  NC=$(tput sgr0)
else
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_MAGENTA=""
  BOLD=""
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
    echo_blue "Getting admin password from 'Secret/argocd-initial-admin-secret'..."
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
  echo_blue "Logging in to ArgoCD..."
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
  echo_blue "Syncing applications with timeout of ${ARGOCD_SYNC_TIMEOUT_SECONDS}s:"
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
    if [[ "$_cmd_stderr" =~ "resources require pruning" ]]; then
      echo_yellow ">>> WARNING: There are resources that need to be PRUNED"
      if [[ "$_prompt_for_prune" == "true" ]]; then
        echo ""
        echo_magenta "Do you want to sync again with PRUNING enabled?"
        echo ""
        echo_red "Pruning DELETES resources that are no longer part of the application."
        echo_red "Check that resources above with '(requires pruning)' can be safely deleted."
        echo ""
        echo_yellow "If you are unsure, respond with 'no' or press ENTER to continue without pruning."
        echo ""
        while true; do
            echo "${COLOR_MAGENTA}${BOLD}OPTIONS:${NC} ${COLOR_RED}${BOLD}yes${NC}, ${COLOR_GREEN}${BOLD}no${NC} (default)"
            echo "${COLOR_MAGENTA}${BOLD}TIMEOUT:${NC} ${ARGOCD_PRUNE_PROMPT_SECONDS} seconds"
            read -r -t "$ARGOCD_PRUNE_PROMPT_SECONDS" -p "${COLOR_MAGENTA}${BOLD}RESPONSE:${NC} " response || echo "<no response, continuing without pruning>"
            case "$response" in
                "YES" | "yes" | "Y" | "y" )
                  echo_yellow ">>> Syncing again with pruning enabled..."
                  sync_argocd_apps "true" "false" "false" "$_resource_selectors" "${_app_names[@]}"
                  break
                  ;;
                "NO" | "no" | "N" | "n" | "" )
                  echo_yellow ">>> Continuing without pruning..."
                  break
                  ;;
                * )
                  echo ""
                  ;;
            esac
        done
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

# wait for an argocd application to be healthy
function argocd_app_wait() {
  local _app_names=("$@")

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Waiting ${ARGOCD_WAIT_TIMEOUT_SECONDS}s for applications to be healthy:"
  local _app_name
  for _app_name in "${_app_names[@]}"; do
    echo_blue " - $_app_name"
  done
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

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Getting status of '${_app_selector}' applications..."
  echo_blue "=========================================================================================="

  # this associative array has "sync wave numbers" as keys, and SPACE-separated "app names" as values
  local -A _sync_waves=()

  # this associative array has "app names" as keys, and "sync status" as values
  local -A _app_sync_statuses=()

  # this associative array has "app names" as keys, and SPACE-separated "resource selectors" as values
  #  - the format of each resource selector is: "GROUP:KIND:NAME"
  local -A _app_force_sync_resources=()

  # build an array of applications to sync
  local _app_name
  local _app_json
  local _app_sync_wave
  local _app_sync_status
  local _app_operation_state
  local _app_operation_state_phase
  local _app_resources
  for _app_name in $(argocd app list -l "$_app_selector" -N "$_app_namespace" -o "name"); do

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
    # TODO: remove once ArgoCD has a way to force sync individual resources
    #       https://github.com/argoproj/gitops-engine/issues/414
    local _app_resource
    local _app_resource_group
    local _app_resource_kind
    local _app_resource_name
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
      _app_resource_status=$(echo "$_app_resource" | jq -r '.status // "Unknown"')
      _app_resource_health=$(echo "$_app_resource" | jq -r '.health // empty')
      _app_resource_health_status=$(echo "$_app_resource_health" | jq -r '.status // "Unknown"')
      _app_resource_requiresPruning=$(echo "$_app_resource" | jq -r '.requiresPruning // false')
      _app_resource_selector="$_app_resource_group:$_app_resource_kind:$_app_resource_name"

      # force sync is only relevant to resources that are not Synced, do not require pruning, and are not Missing
      _app_resource_force_sync="false"
      if [[ "$_app_resource_status" != "Synced" &&
            "$_app_resource_requiresPruning" == "false" &&
            "$_app_resource_health_status" != "Missing"
      ]]; then
        # kyverno ClusterPolicies with "generate" type rules cant be updated without a forced sync
        #  - https://github.com/kyverno/kyverno/issues/7718
        #  - in deployKF, all such policies have names containing "clone" or "generate"
        if [[ "$_app_resource_group" == "kyverno.io" &&
              "$_app_resource_kind" == "ClusterPolicy" &&
              ("$_app_resource_name" =~ "clone" || "$_app_resource_name" =~ "generate")
        ]]; then
          _app_resource_force_sync="true"
        fi
      fi

      # add the resource selector to the array
      if [[ "$_app_resource_force_sync" == "true" ]]; then
        if [[ -v _app_force_sync_resources["$_app_name"] ]]; then
          _app_force_sync_resources[$_app_name]+=" $_app_resource_selector"
        else
          _app_force_sync_resources[$_app_name]="$_app_resource_selector"
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
      echo_yellow ">>>  - $_app_name (status: ${_app_sync_statuses[$_app_name]})"
    done
  done

  # sync out-of-sync applications in each sync wave
  local _app_name
  local _sync_wave
  local _sync_wave_apps
  for _sync_wave in "${_sync_waves_sorted[@]}"; do
    IFS=' ' read -r -a _sync_wave_apps <<< "${_sync_waves[$_sync_wave]}"

    # build an array of out-of-sync applications in this sync wave
    local -a _out_of_sync_apps=()
    for _app_name in "${_sync_wave_apps[@]}"; do
      if [[ "${_app_sync_statuses[$_app_name]}" != "Synced" ]]; then
        _out_of_sync_apps+=("$_app_name")
      fi
    done

    # sync the out-of-sync applications
    if [[ -n "${_out_of_sync_apps[*]}" ]]; then

      # if there are resources that require a forced sync, sync them first
      local _resource_array_str
      local _resource_str
      if [[ ${#_app_force_sync_resources[@]} -gt 0 ]]; then
        for _app_name in "${_out_of_sync_apps[@]}"; do
          if [[ -v _app_force_sync_resources["$_app_name"] ]]; then
            _resource_array_str="${_app_force_sync_resources[$_app_name]}"
            echo ""
            echo_yellow ">>> Syncing resources that require a forced sync from '$_app_name':"
            for _resource_str in $_resource_array_str; do
              echo_yellow ">>>  - $_resource_str"
            done
            sync_argocd_apps "false" "false" "true" "$_resource_array_str" "$_app_name"
          fi
        done
      fi

      # sync the out-of-sync applications
      case "$ARGOCD_PRUNE_MODE" in
        "always")
          sync_argocd_apps "true" "false" "false" "" "${_out_of_sync_apps[@]}"
          ;;
        "prompt")
          sync_argocd_apps "false" "true" "false" "" "${_out_of_sync_apps[@]}"
          ;;
        "skip")
          sync_argocd_apps "false" "false" "false" "" "${_out_of_sync_apps[@]}"
          ;;
        *)
          echo_red ">>> ERROR: Invalid ARGOCD_PRUNE_MODE: '$ARGOCD_PRUNE_MODE'"
          exit 1
          ;;
      esac

      # wait for the out-of-sync applications to be healthy
      argocd_app_wait "${_out_of_sync_apps[@]}"
    fi

    # wait for ALL applications in this sync wave to be healthy
    # NOTE: this includes applications that were already in-sync before the sync command
    if [[ -n "${_sync_wave_apps[*]}" ]]; then
      argocd_app_wait "${_sync_wave_apps[@]}"
    fi
  done
}

#######################################
# MAIN
#######################################

# authenticate to argocd
argocd_login "$ARGOCD_SERVER_URL" "$ARGOCD_NAMESPACE" "$ARGOCD_USERNAME" "$ARGOCD_PASSWORD"

# sync the "deploykf-app-of-apps" application
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/name=deploykf-app-of-apps"

# sync the "deploykf-namespaces" application
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/name=deploykf-namespaces"

# sync all applications in the "deploykf-dependencies" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=deploykf-dependencies"

# sync all applications in the "deploykf-core" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=deploykf-core"

# sync all applications in the "deploykf-opt" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=deploykf-opt"

# sync all applications in the "deploykf-tools" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=deploykf-tools"

# sync all applications in the "kubeflow-dependencies" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=kubeflow-dependencies"

# sync all applications in the "kubeflow-tools" group
sync_argocd "$ARGOCD_NAMESPACE" "app.kubernetes.io/component=kubeflow-tools"