#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

ARGOCD_NAMESPACE="argocd"

# create or update ConfigMap/argocd-deploykf-plugin
kubectl create configmap argocd-deploykf-plugin \
  --namespace="$ARGOCD_NAMESPACE" \
  --from-file=plugin.yaml=./argocd-install/deploykf-plugin/plugin.yaml \
  --dry-run=client \
  --output=yaml \
  | kubectl apply --namespace="$ARGOCD_NAMESPACE" --filename=-

# create PersistentVolumeClaim/argocd-deploykf-plugin-assets
kubectl apply \
  --namespace="$ARGOCD_NAMESPACE" \
  --filename=./argocd-install/deploykf-plugin/assets-pvc.yaml

# patch Deployment/argocd-repo-server
kubectl patch deployment argocd-repo-server \
  --namespace="$ARGOCD_NAMESPACE" \
  --patch-file=./argocd-install/deploykf-plugin/repo-server-patch.yaml