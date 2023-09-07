#!/usr/bin/env bash

set -euo pipefail

THIS_SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
cd "$THIS_SCRIPT_PATH"

GENERATOR_SOURCE_PATH="./generator"
GENERATOR_RUNTIME_PATH="$GENERATOR_SOURCE_PATH/runtime"
GENERATOR_OUTPUT_PATH="./GENERATOR_OUTPUT"
CUSTOM_VALUES_PATH="./sample-values.yaml"

# clean the generator output directory
# NOTE: we only clean the output directory if a '.deploykf_output' marker file is present
if [ -d "$GENERATOR_OUTPUT_PATH" ]; then
  if [ -f "$GENERATOR_OUTPUT_PATH/.deploykf_output" ]; then
    rm -rf "$GENERATOR_OUTPUT_PATH"
  else
    echo "ERROR: output directory '$GENERATOR_OUTPUT_PATH' is not safe to clean, no '.deploykf_output' marker found"
    exit 1
  fi
fi

# create the generator output directory and marker file
mkdir -p "$GENERATOR_OUTPUT_PATH"
echo -n "{}" > "$GENERATOR_OUTPUT_PATH/.deploykf_output"

# create the runtime directory
mkdir -p "$GENERATOR_RUNTIME_PATH"

# populate the runtime templates
echo -n "$GENERATOR_SOURCE_PATH/templates" > "$GENERATOR_RUNTIME_PATH/input_dir"
echo -n "$GENERATOR_OUTPUT_PATH" > "$GENERATOR_RUNTIME_PATH/output_dir"

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
  --template "helpers=$GENERATOR_SOURCE_PATH/helpers/" \
  --template "runtime=$GENERATOR_SOURCE_PATH/runtime/"

# PHASE 2: populate generator output directory
gomplate \
  --input-dir="$GENERATOR_SOURCE_PATH/templates" \
  --output-dir="$GENERATOR_OUTPUT_PATH" \
  --left-delim "{{<" \
  --right-delim ">}}" \
  --datasource "Values_default=$GENERATOR_SOURCE_PATH/default_values.yaml" \
  --datasource "Values_custom=$CUSTOM_VALUES_PATH" \
  --context "Values=merge:Values_custom|Values_default" \
  --template "helpers=$GENERATOR_SOURCE_PATH/helpers/" \
  --template "runtime=$GENERATOR_SOURCE_PATH/runtime/"
