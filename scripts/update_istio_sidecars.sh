#!/usr/bin/env bash

set -euo pipefail

#
# This script restarts Pods with istio sidecar versions that do not match the current Istio version.
#

#######################################
# CONFIGURATION
#######################################

# the istio namespace
ISTIO_NAMESPACE="${ISTIO_NAMESPACE:-istio-system}"

# the istio revision
ISTIO_REVISION="${ISTIO_REVISION:-default}"

#######################################
# REQUIREMENTS
#######################################

# ensure bash version 4.4+
if [[ ${BASH_VERSINFO[0]} -lt 4 || (${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 4) ]]; then
  echo ">>> ERROR: Bash version 4.4+ is required to run this script, current version: '${BASH_VERSION}'"
  exit 1
fi

# ensure 'istioctl' is installed
if [[ -z "$(command -v istioctl)" ]]; then
  echo ">>> ERROR: 'istioctl' must be installed to run this script"
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

# ask the user to confirm restarting the controllers
function ask_restart_controllers() {
  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Prompting for confirmation..."
  echo_blue "=========================================================================================="
  echo ""
  echo_red ">>> Restarting Pods will cause a service disruption!"
  echo_red ">>> When restarting Notebook Pods, all in-progress and unsaved work will be lost!"
  echo ""
  while true; do
    echo "${COLOR_MAGENTA}${BOLD}Do you want to RESTART all Pods listed above? ${NC}(${BOLD}${COLOR_RED}${UL_S}Y${UL_E}ES${NC} restart / ${BOLD}${COLOR_GREEN}${UL_S}N${UL_E}O${NC} exit)"
    read -r -p "${COLOR_MAGENTA}${BOLD}RESPONSE:${NC} " response || echo "<no response>"
    case $(echo "$response" | tr '[:upper:]' '[:lower:]') in
       "yes" | "y" )
          echo ""
          echo_yellow ">>> INFO: proceeding with restart..."
          break
          ;;
        "no" | "n" )
          echo ""
          echo_yellow ">>> INFO: exiting..."
          exit 0
          ;;
        * )
          echo ""
          ;;
    esac
  done
}

# restart a pod controller in a namespace
function rollout_restart() {
  local _namespace="$1"
  local _controller_kind="$2"
  local _controller_name="$3"

  echo_yellow ">>> INFO: restarting $_controller_kind/$_controller_name in namespace '$_namespace'..."
  kubectl rollout restart "$_controller_kind/$_controller_name" -n "$_namespace"
}

# get the controller of a Pod
#  - returns nothing if the controller is not found
function get_pod_controller() {
  local _namespace="$1"
  local _pod_name="$2"

  # initialize return value
  #  - FORMAT: "<controller_kind>:<controller_name>"
  #  - NOTE: this is a global variable, caller should check the value of this variable
  pod_controller=""

  # get the Pod JSON
  local _pod_json
  _pod_json=$(kubectl get pod "$_pod_name" -n "$_namespace" -o json)

  # extract the first owner reference
  local _owner_ref
  local _owner_ref__kind
  local _owner_ref__name
  local _owner_ref__controller
  _owner_ref=$(echo "$_pod_json" | jq -c '.metadata.ownerReferences[0] // empty')
  _owner_ref__kind=$(echo "$_owner_ref" | jq -r '.kind // empty')
  _owner_ref__name=$(echo "$_owner_ref" | jq -r '.name // empty')
  _owner_ref__controller=$(echo "$_owner_ref" | jq -r '.controller // empty')

  # check if the owner reference is empty
  if [[ -z "$_owner_ref__kind" || -z "$_owner_ref__name" ]]; then
    echo_red ">>> WARNING: unable to determine owner of Pod '$_pod_name' in namespace '$_namespace', skipping..."
    return
  fi

  # if the owner reference is not a controller, fail
  if [[ "$_owner_ref__controller" != "true" ]]; then
    echo_red ">>> ERROR: first owner of Pod '$_pod_name' in namespace '$_namespace' is not a controller"
    exit 1
  fi

  # if the owner reference is a ReplicaSet, then get the Deployment
  if [[ "$_owner_ref__kind" == "ReplicaSet" ]]; then

    # get the ReplicaSet JSON
    local _rs_json
    _rs_json=$(kubectl get replicaset "$_owner_ref__name" -n "$_namespace" -o json)

    # extract the owner reference of the ReplicaSet
    local _rs_owner_ref
    local _rs_owner_ref__kind
    local _rs_owner_ref__name
    local _rs_owner_ref__controller
    _rs_owner_ref=$(echo "$_rs_json" | jq -c '.metadata.ownerReferences[0] // empty')
    _rs_owner_ref__kind=$(echo "$_rs_owner_ref" | jq -r '.kind // empty')
    _rs_owner_ref__name=$(echo "$_rs_owner_ref" | jq -r '.name // empty')
    _rs_owner_ref__controller=$(echo "$_rs_owner_ref" | jq -r '.controller // empty')

    # check if the owner reference is empty
    if [[ -z "$_rs_owner_ref__kind" || -z "$_rs_owner_ref__name" ]]; then
      echo_red ">>> WARNING: unable to determine owner of ReplicaSet '$_owner_ref__name' in namespace '$_namespace', skipping..."
      return
    fi

    # if the owner reference is not a controller, fail
    if [[ "$_rs_owner_ref__controller" != "true" ]]; then
      echo_red ">>> ERROR: first owner of ReplicaSet '$_owner_ref__name' in namespace '$_namespace' is not a controller"
      exit 1
    fi

    # return the owner reference
    pod_controller="${_rs_owner_ref__kind}:${_rs_owner_ref__name}"
    return
  fi

  # return the owner reference
  pod_controller="${_owner_ref__kind}:${_owner_ref__name}"
}

# restart all Istio sidecars with incorrect versions
function restart_istio_sidecars() {
  local _istio_namespace=$1
  local _istio_revision=$2

  # retrieve the version information from Istio
  local _version_json
  _version_json=$(istioctl version --revision "$_istio_revision" --istioNamespace "$_istio_namespace" -o json)

  # extract the list of `meshVersion` objects from the JSON
  # SPEC: https://github.com/istio/istio/blob/1.21.2/pkg/version/cobra.go#L31
  local _mesh_versions_json
  _mesh_versions_json=$(echo "$_version_json" | jq -c '.meshVersion[]?')

  # extract the list of `dataPlaneVersion` objects from the JSON
  # SPEC: https://github.com/istio/istio/blob/1.21.2/pkg/version/cobra.go#L32
  local _data_plane_versions_json
  _data_plane_versions_json=$(echo "$_version_json" | jq -c '.dataPlaneVersion[]?')

  # we need to find the current Istio version for this revision
  local _current_istio_version=""

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Getting Istio version for revision '$_istio_revision'"
  echo_blue "=========================================================================================="

  # loop through the mesh versions
  local _mesh_version
  local _mesh_version__component
  local _mesh_version__revision
  local _mesh_version__info
  local _mesh_version__info__version
  IFS=$'\n'
  for _mesh_version in $_mesh_versions_json; do
    _mesh_version__component=$(echo "$_mesh_version" | jq -r '.Component // empty')
    _mesh_version__revision=$(echo "$_mesh_version" | jq -r '.Revision // empty')
    _mesh_version__info=$(echo "$_mesh_version" | jq -r '.Info // empty')
    _mesh_version__info__version=$(echo "$_mesh_version__info" | jq -r '.version // empty')

    # we are looking for a `pilot` component with the correct revision
    if [[ "$_mesh_version__component" == "pilot" && "$_mesh_version__revision" == "$_istio_revision" ]]; then
      _current_istio_version="$_mesh_version__info__version"
      break
    fi
  done
  unset IFS

  # check if the Istio version tag was found
  if [[ -z "$_current_istio_version" ]]; then
    echo_red ">>> ERROR: could not find current Istio version for revision '$_istio_revision'"
    exit 1
  fi

  echo_yellow ">>> INFO: current Istio VERSION is '$_current_istio_version' for REVISION '$_istio_revision'"

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Getting Pods with INCORRECT Istio sidecar versions"
  echo_blue "=========================================================================================="

  # pods with INCORRECT Istio sidecar versions
  #   - this associative array has "namespace" as key, and SPACE-separated
  #     "<controller_kind>:<controller_name>:<pod_name>:<istio_version>" as the value
  local -A _namespace_pods_bad=()

  # loop through the data plane versions
  local _data_plane_version
  local _data_plane_version__id
  local _pod_istio_version
  local _pod_name
  local _pod_namespace
  local _pod_key
  IFS=$'\n'
  for _data_plane_version in $_data_plane_versions_json; do
    _data_plane_version__id=$(echo "$_data_plane_version" | jq -r '.ID // empty')
    _pod_istio_version=$(echo "$_data_plane_version" | jq -r '.IstioVersion // empty')

    # NOTE: the format of ID is "<pod_name>.<pod_namespace>"
    _pod_name=$(echo "$_data_plane_version__id" | cut -d'.' -f1)
    _pod_namespace=$(echo "$_data_plane_version__id" | cut -d'.' -f2)

    # check if the Istio version is INCORRECT
    if [[ "$_pod_istio_version" != "$_current_istio_version" ]]; then

      # get the pod's controller resource
      get_pod_controller "$_pod_namespace" "$_pod_name"
      if [[ -z "$pod_controller" ]]; then
        continue
      fi

      # add the pod to the list
      _pod_key="${pod_controller}:${_pod_name}:${_pod_istio_version}"
      if [[ -v _namespace_pods_bad["$_pod_namespace"] ]]; then
        _namespace_pods_bad[$_pod_namespace]+=" $_pod_key"
      else
        _namespace_pods_bad[$_pod_namespace]="$_pod_key"
      fi
    fi
  done
  unset IFS

  if [[ ${#_namespace_pods_bad[@]} -eq 0 ]]; then
    echo_yellow ">>> INFO: all Pods have the CORRECT Istio sidecar version"
    return
  else
    echo_red ">>> WARNING: the following Pods have INCORRECT Istio sidecar versions"
  fi

  # store controllers to restart
  local -a _controllers_to_restart=()

  # loop through the namespaces and print the pods with INCORRECT Istio sidecar versions
  local _pod_controller_kind
  local _pod_controller_name
  for _namespace in $(echo "${!_namespace_pods_bad[@]}" | tr ' ' '\n' | sort -u); do
    echo ""
    echo "${COLOR_YELLOW}${BOLD}Namespace${NC}${COLOR_YELLOW}: ${_namespace}${NC}"
    for _pod_key in $(echo "${_namespace_pods_bad[$_namespace]}" | tr ' ' '\n' | sort -u); do
      _pod_controller_kind=$(echo "$_pod_key" | cut -d':' -f1)
      _pod_controller_name=$(echo "$_pod_key" | cut -d':' -f2)
      _pod_name=$(echo "$_pod_key" | cut -d':' -f3)
      _pod_istio_version=$(echo "$_pod_key" | cut -d':' -f4)
      echo "${COLOR_YELLOW} - ${BOLD}${_pod_controller_kind}${NC}${COLOR_YELLOW}: ${_pod_controller_name} | ${BOLD}Pod${NC}${COLOR_YELLOW}: ${_pod_name} | ${BOLD}Istio${NC}${COLOR_YELLOW}: ${_pod_istio_version}${NC}"
      _controllers_to_restart+=("$_namespace:$_pod_controller_kind:$_pod_controller_name")
    done
  done

  # ask the user to confirm restarting the controllers
  ask_restart_controllers

  echo ""
  echo_blue "=========================================================================================="
  echo_blue "Restarting Pods..."
  echo_blue "=========================================================================================="

  # restart the controllers
  local _controller
  local _controller__namespace
  local _controller__kind
  local _controller__name
  for _controller in "${_controllers_to_restart[@]}"; do
    _controller__namespace=$(echo "$_controller" | cut -d':' -f1)
    _controller__kind=$(echo "$_controller" | cut -d':' -f2)
    _controller__name=$(echo "$_controller" | cut -d':' -f3)
    rollout_restart "$_controller__namespace" "$_controller__kind" "$_controller__name"
  done
}

#######################################
# MAIN
#######################################

# restart all Istio sidecars with incorrect versions
restart_istio_sidecars "$ISTIO_NAMESPACE" "$ISTIO_REVISION"
