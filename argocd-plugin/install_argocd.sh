#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

ARGOCD_NAMESPACE="argocd"

# create the argocd namespace
kubectl create ns "$ARGOCD_NAMESPACE" || echo "namespace '$ARGOCD_NAMESPACE' already exists"

# install argocd
kubectl kustomize ./argocd-install | kubectl apply --namespace "$ARGOCD_NAMESPACE" -f -