#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

ARGOCD_NAMESPACE="argocd"
HELM_RELEASE_NAME="argocd"

# add the argocd helm repo
helm repo add "argo" https://argoproj.github.io/argo-helm

# install argocd with helm
# NOTE: the chart and argocd versions are NOT aligned
#       https://artifacthub.io/packages/helm/argo/argo-cd
helm install "$HELM_RELEASE_NAME" "argo/argo-cd" \
  --namespace "$ARGOCD_NAMESPACE" \
  --create-namespace \
  --version "6.7.18" \
  --values ./values.yaml