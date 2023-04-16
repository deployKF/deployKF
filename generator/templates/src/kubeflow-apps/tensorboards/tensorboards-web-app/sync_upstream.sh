#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

# upstream configs
UPSTREAM_REPO="github.com/kubeflow/manifests"
UPSTREAM_PATH="apps/tensorboard/tensorboards-web-app/upstream/overlays/istio"
UPSTREAM_REF="f038f81df39f3606c14ad52e06f60f3d9c5bddfb" # v1.6.1

# output configs
OUTPUT_PATH="./upstream"

# clean the generator output directory
rm -rf "$OUTPUT_PATH"

# localize the upstream resources with kustomize
# - https://kubectl.docs.kubernetes.io/references/kustomize/cmd/localize/
kustomize localize "${UPSTREAM_REPO}/${UPSTREAM_PATH}?ref=${UPSTREAM_REF}" "$OUTPUT_PATH"
