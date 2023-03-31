#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

GENERATOR_SOURCE_PATH="./generator"
GENERATOR_OUTPUT_PATH="./GENERATOR_OUTPUT"
CUSTOM_VALUES_PATH="./values.yaml"

# clean the generator output directory
rm -rf "$GENERATOR_OUTPUT_PATH"

# suppress the generation of empty files
export GOMPLATE_SUPPRESS_EMPTY=true

# PHASE 1: render our `.gomplateignore_template` files
gomplate \
  --input-dir="$GENERATOR_SOURCE_PATH/templates" \
  --output-map="$GENERATOR_SOURCE_PATH/templates/{{< .in | strings.ReplaceAll \".gomplateignore_template\" \".gomplateignore\" >}}" \
  --include ".gomplateignore_template" \
  --left-delim "{{<" \
  --right-delim ">}}" \
  --datasource "Values_default=$GENERATOR_SOURCE_PATH/default_values.yaml" \
  --datasource "Values_custom=$CUSTOM_VALUES_PATH" \
  --context "Values=merge:Values_custom|Values_default" \
  --template "$GENERATOR_SOURCE_PATH/helpers/"

# PHASE 2: populate generator output directory
gomplate \
  --input-dir="$GENERATOR_SOURCE_PATH/templates" \
  --output-dir="$GENERATOR_OUTPUT_PATH" \
  --left-delim "{{<" \
  --right-delim ">}}" \
  --datasource "Values_default=$GENERATOR_SOURCE_PATH/default_values.yaml" \
  --datasource "Values_custom=$CUSTOM_VALUES_PATH" \
  --context "Values=merge:Values_custom|Values_default" \
  --template "$GENERATOR_SOURCE_PATH/helpers/"
