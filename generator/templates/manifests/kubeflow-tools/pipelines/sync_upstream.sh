#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

# upstream configs
UPSTREAM_REPO="github.com/kubeflow/pipelines"
UPSTREAM_PATH="manifests/kustomize/env/cert-manager/platform-agnostic-multi-user"
UPSTREAM_REF="f328f0b588c35cdf1e5b31638fbe3596b2f38413" # v2.1.0

# output configs
OUTPUT_PATH="./upstream"

# clean the generator output directory
rm -rf "$OUTPUT_PATH"

# localize the upstream resources with kustomize
# - https://kubectl.docs.kubernetes.io/references/kustomize/cmd/localize/
kustomize localize "${UPSTREAM_REPO}/${UPSTREAM_PATH}?ref=${UPSTREAM_REF}" "$OUTPUT_PATH"
