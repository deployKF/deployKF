#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

ARGOCD_NAMESPACE="argocd"

# apply the argocd apps
kubectl apply -f ./app-of-apps.yaml --namespace "$ARGOCD_NAMESPACE"