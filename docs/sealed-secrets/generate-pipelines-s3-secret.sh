#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)

KUBEFLOW_NAMESPACE="kubeflow"
SEALED_SECRETS_NAMESPACE="sealed-secrets"
SEALED_SECRETS_CONTROLLER_NAME="sealed-secrets"

echo "----------------"
echo "Generating 'pipelines-s3-secret' SealedSecret"
echo "----------------"

# info about `read`: https://github.com/koalaman/shellcheck/wiki/SC2162
echo "Enter AWS_ACCESS_KEY_ID for S3:"
IFS= read -r S3_ACCESSKEY
echo "Enter AWS_SECRET_ACCESS_KEY for S3:"
IFS= read -r -s S3_SECRETKEY

# ensure output directory exists
mkdir -p "$SCRIPT_PATH/out"

kubectl create secret generic \
   "pipelines-s3-secret" \
   --namespace="$KUBEFLOW_NAMESPACE" \
   --dry-run=client \
   --from-literal="S3_ACCESSKEY=${S3_ACCESSKEY}" \
   --from-literal="S3_SECRETKEY=${S3_SECRETKEY}" \
   -o json \
 | kubeseal \
   --controller-namespace="$SEALED_SECRETS_NAMESPACE" \
   --controller-name="$SEALED_SECRETS_CONTROLLER_NAME" \
   -o yaml \
 > "$SCRIPT_PATH/out/pipelines-s3-secret-sealedsecret.yaml"
