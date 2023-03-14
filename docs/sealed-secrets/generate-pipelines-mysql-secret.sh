#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)

KUBEFLOW_NAMESPACE="kubeflow"
SEALED_SECRETS_NAMESPACE="sealed-secrets"
SEALED_SECRETS_CONTROLLER_NAME="sealed-secrets"

echo "----------------"
echo "Generating 'pipelines-mysql-secret' SealedSecret"
echo "----------------"

# info about `read`: https://github.com/koalaman/shellcheck/wiki/SC2162
echo "Enter MySQL Username:"
IFS= read -r mysql_username
echo "Enter MySQL Password:"
IFS= read -r -s mysql_password

# ensure output directory exists
mkdir -p "$SCRIPT_PATH/out"

kubectl create secret generic \
   "pipelines-mysql-secret" \
   --namespace="$KUBEFLOW_NAMESPACE" \
   --dry-run=client \
   --from-literal="username=${mysql_username}" \
   --from-literal="password=${mysql_password}" \
   -o json \
 | kubeseal \
   --controller-namespace="$SEALED_SECRETS_NAMESPACE" \
   --controller-name="$SEALED_SECRETS_CONTROLLER_NAME" \
   -o yaml \
 > "$SCRIPT_PATH/out/pipelines-mysql-secret-sealedsecret.yaml"
