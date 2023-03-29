#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

# clean the generator output directory
rm -rf ./GENERATOR_OUTPUT/

# suppress the generation of empty files
export GOMPLATE_SUPPRESS_EMPTY=true

# populate generator output directory
gomplate \
  --input-dir='./generator/templates' \
  --output-dir='./GENERATOR_OUTPUT' \
  --left-delim '{{<' \
  --right-delim '>}}' \
  --datasource 'Values_default=./generator/default_values.yaml' \
  --datasource 'Values_custom=./values.yaml' \
  --context 'Values=merge:Values_custom|Values_default' \
  --template './generator/helpers/'
