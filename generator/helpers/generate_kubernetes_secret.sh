#!/usr/bin/env bash

## This script is used by jobs which generate kubernetes secrets if they are not already present.
##
## It reads the following environment variables:
##  - SECRET_NAME: the name of the secret to generate
##  - SECRET_KEYS: a JSON object whose keys are the names of the keys in the secret, and values are objects with the following properties:
##    - "length": the length of the value to generate (default: 32)
##    - "characters": a JSON object with the following properties: (default: all false)
##       - "lowercase": if the generated value can contain lowercase letters: a-z
##       - "uppercase": if the generated value can contain uppercase letters: A-Z
##       - "special": if the generated value can contain special characters: !@#$%^&*()_-=+[]{}\|;:'",.<>/?`~
##    - "base64": a JSON object with the following properties:
##       - "encode": if the generated value will be base64 encoded (default: false)
##       - "url_safe": if the alternate "URL and Filename safe" RFC 4648 encoding is used (default: false)
##       - "remove_pad": if padding characters are removed from the encoded value (default: false)
##  - SECRET_LABEL: the label used to identify previously generated secrets
##  - SECRET_EXTRA_LABELS: a JSON object whose keys and values are used as additional labels on the secret
##  - SECRET_EXTRA_ANNOTATIONS: a JSON object whose keys and values are used as additional annotations on the secret

set -eou pipefail

#######################################
## Functions
#######################################

## generate a secure random value of a given length and character set
## NOTE: characters are chosen with uniform distribution from the character set
function generate_random_value() {
  local _length="$1"
  local _charset_has_lowercase="$2"
  local _charset_has_uppercase="$3"
  local _charset_has_numbers="$4"
  local _charset_has_special="$5"
  local _base64_encode="$6"
  local _base64_url_safe="$7"
  local _base64_remove_pad="$8"

  ## initialize return value
  ## NOTE: this is a global variable
  random_value=""

  ## define the character set
  local _charset=""
  if [[ "$_charset_has_numbers" == "true" ]]; then
    _charset+='0123456789'
  fi
  if [[ "$_charset_has_lowercase" == "true" ]]; then
    _charset+='abcdefghijklmnopqrstuvwxyz'
  fi
  if [[ "$_charset_has_uppercase" == "true" ]]; then
    _charset+='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  fi
  if [[ "$_charset_has_special" == "true" ]]; then
    _charset+='!@#$%^&*()_-=+[]{}\|;:,.<>/?`~'
    _charset+="'"
    _charset+='"'
  fi

  ## calculate the length of the character set
  local _charset_length
  _charset_length=${#_charset}

  ## check if the character set is empty
  if [[ "$_charset_length" == "0" ]]; then
    echo "ERROR: character set may not be empty"
    exit 1
  fi

  ## calculate the maximum value that is evenly divisible by charset length
  ## NOTE: this is used to avoid modulo bias making the earlier characters more likely
  ##       by disregarding random values larger than this
  ## NOTE: division of integers in bash is equivalent to floor division
  local _max_int
  _max_int=$(((255 / _charset_length) * _charset_length))

  ## the number of random bytes to read in each batch
  local _batch_size=1024

  local -a _result=()
  local _random_ints
  local _int
  local _char_index

  while ((${#_result[@]} < _length)); do
    ## read a batch of random bytes and convert them to unsigned integers
    ## NOTE: the resulting integers will be in the range [0, 255]
    _random_ints=($(od -v -A n -t u1 -N $_batch_size /dev/urandom))

    ## iterate over the random integers
    for _int in "${_random_ints[@]}"; do

      ## only use this random value if it's smaller than the maximum value
      if ((_int < _max_int)); then

        ## get a valid index in the character set using modulo
        ## NOTE: the index will be in the range [0, _charset_length)
        _char_index=$((_int % _charset_length))
        _result+=("${_charset:_char_index:1}")

        ## break if we have enough characters
        if ((${#_result[@]} == _length)); then
          break
        fi
      fi
    done
  done

  ## construct the final string from the array of characters
  random_value=$(printf "%s" "${_result[@]}")

  ## if base64 encoding is requested, encode the random value
  if [[ "$_base64_encode" == "true" ]]; then
    random_value=$(echo -n "$random_value" | base64)

    ## if requested, use the "URL and Filename safe" encoding
    if [[ "$_base64_url_safe" == "true" ]]; then
      random_value=$(echo -n "$random_value" | tr '+/' '-_')
    fi

    ## if requested, remove padding characters
    if [[ "$_base64_remove_pad" == "true" ]]; then
      random_value=$(echo -n "$random_value" | tr -d '=')
    fi
  fi
}

## read a kubernetes secret and extract its data and labels into associative arrays
function read_kube_secret() {
  local _secret_name="$1"

  ## unset the associative array return values
  unset secret_data
  unset secret_labels

  ## initialize return values
  ## NOTE: these are global variables
  secret_exists=""
  declare -gA secret_data
  declare -gA secret_labels

  ## get the secret
  local _secret
  _secret=$(kubectl get secret "$_secret_name" -o json 2>/dev/null || echo "")

  ## check if the secret exists
  if [[ -z "$_secret" ]]; then
    secret_exists="false"
  else
    secret_exists="true"

    ## populate the secret_data associative array (base64 decoded)
    local _key
    local _value
    for _key in $(echo "$_secret" | jq -r '.data // empty | keys[]'); do
      _value=$(echo "$_secret" | jq -r --arg k "$_key" '.data[$k]')
      secret_data["$_key"]=$(echo "$_value" | base64 --decode)
    done

    ## populate the secret_labels associative array
    for _key in $(echo "$_secret" | jq -r '.metadata.labels // empty | keys[]'); do
      _value=$(echo "$_secret" | jq -r --arg k "$_key" '.metadata.labels[$k]')
      secret_labels["$_key"]="$_value"
    done
  fi
}

## generate a secret and write it to kubernetes
function generate_kube_secret() {
  local _secret_name="$1"
  local _secret_keys="$2"
  local _secret_label="$3"
  local _secret_extra_labels="$4"
  local _secret_extra_annotations="$5"
  local _delete_existing="$6"

  ## unset the associative array return values
  unset generated_secret_data

  ## initialize return values
  ## NOTE: these are global variables
  declare -gA generated_secret_data

  ## delete the existing secret if requested
  if [[ "$_delete_existing" == "true" ]]; then
    echo "WARNING: deleting existing secret '$_secret_name'"
    kubectl delete secret "$_secret_name"
  fi

  ## populate the generated_secret_data associative array with random values
  local _key_name
  local _key_configs
  local _length
  local _characters
  local _characters_lowercase
  local _characters_uppercase
  local _characters_numbers
  local _characters_special
  local _base64
  local _base64_encode
  local _base64_url_safe
  local _base64_remove_pad
  for _key_name in $(echo "$_secret_keys" | jq -r '. // empty | keys[]'); do
    ## unpack the key configurations
    _key_configs=$(echo "$_secret_keys" | jq -r --arg k "$_key_name" '.[$k]')
    _length=$(echo "$_key_configs" | jq -r '.length // 32')
    _characters=$(echo "$_key_configs" | jq -r '.characters // empty')
    _characters_lowercase=$(echo "$_characters" | jq -r '.lowercase // false')
    _characters_uppercase=$(echo "$_characters" | jq -r '.uppercase // false')
    _characters_numbers=$(echo "$_characters" | jq -r '.numbers // false')
    _characters_special=$(echo "$_characters" | jq -r '.special // false')
    _base64=$(echo "$_key_configs" | jq -r '.base64 // empty')
    _base64_encode=$(echo "$_base64" | jq -r '.encode // false')
    _base64_url_safe=$(echo "$_base64" | jq -r '.url_safe // false')
    _base64_remove_pad=$(echo "$_base64" | jq -r '.remove_pad // false')

    ## generate and store the random value
    echo "INFO: generating random value for key '$_key_name' with length '$_length' (characters: lowercase=$_characters_lowercase,uppercase=$_characters_uppercase,numbers=$_characters_numbers,special=$_characters_special; base64: encode=$_base64_encode,url_safe=$_base64_url_safe,remove_pad=$_base64_remove_pad)"
    generate_random_value "$_length" "$_characters_lowercase" "$_characters_uppercase" "$_characters_numbers" "$_characters_special" "$_base64_encode" "$_base64_url_safe" "$_base64_remove_pad"
    generated_secret_data["$_key_name"]="$random_value"
  done

  ## build an array of `--from-literal` arguments
  local -a _from_literal_args=()
  for _key_name in "${!generated_secret_data[@]}"; do
    _from_literal_args+=("--from-literal=$_key_name=${generated_secret_data[$_key_name]}")
  done

  ## build an array of annotation name=value arguments
  local -a _annotation_pair_args=()
  local _annotation_name
  local _annotation_value
  for _annotation_name in $(echo "$_secret_extra_annotations" | jq -r '. // empty | keys[]'); do
    _annotation_value=$(echo "$_secret_extra_annotations" | jq -r --arg k "$_annotation_name" '.[$k]')
    _annotation_pair_args+=("$_annotation_name=$_annotation_value")
  done

  ## build an array of label name=value arguments
  local -a _label_pair_args=()
  local _label_name
  local _label_value
  for _label_name in $(echo "$_secret_extra_labels" | jq -r '. // empty | keys[]'); do
    _label_value=$(echo "$_secret_extra_labels" | jq -r --arg k "$_label_name" '.[$k]')
    _label_pair_args+=("$_label_name=$_label_value")
  done

  ## use the current epoch time as the generated secret label value
  local _current_epoch
  _current_epoch=$(date +%s)
  _label_pair_args+=("$_secret_label=$_current_epoch")

  ## create the secret
  kubectl create secret generic "$_secret_name" \
    "${_from_literal_args[@]}" --dry-run=client -o yaml |
    kubectl label --local -f - --dry-run=client -o yaml "${_label_pair_args[@]}" |
    kubectl annotate --local -f - --dry-run=client -o yaml "${_annotation_pair_args[@]}" |
    kubectl apply -f -
}

#######################################
## Main
#######################################

## verify that the required environment variables are set
if [[ -z "${SECRET_NAME:-}" ]]; then
  echo "ERROR: environment variable SECRET_NAME is not set"
  exit 1
fi
if [[ -z "${SECRET_KEYS:-}" ]]; then
  echo "ERROR: environment variable SECRET_KEYS is not set"
  exit 1
fi
if [[ -z "${SECRET_LABEL:-}" ]]; then
  echo "ERROR: environment variable SECRET_LABEL is not set"
  exit 1
fi
if [[ -z "${SECRET_EXTRA_LABELS:-}" ]]; then
  echo "ERROR: environment variable SECRET_EXTRA_LABELS is not set"
  exit 1
fi
if [[ -z "${SECRET_EXTRA_ANNOTATIONS:-}" ]]; then
  echo "ERROR: environment variable SECRET_EXTRA_ANNOTATIONS is not set"
  exit 1
fi

## verify that environment variables contain valid json
if ! jq -e . >/dev/null 2>&1 <<<"$SECRET_KEYS"; then
  echo "ERROR: environment variable SECRET_KEYS does not contain valid JSON"
  exit 1
fi
if ! jq -e . >/dev/null 2>&1 <<<"$SECRET_EXTRA_LABELS"; then
  echo "ERROR: environment variable SECRET_EXTRA_LABELS does not contain valid JSON"
  exit 1
fi
if ! jq -e . >/dev/null 2>&1 <<<"$SECRET_EXTRA_ANNOTATIONS"; then
  echo "ERROR: environment variable SECRET_EXTRA_ANNOTATIONS does not contain valid JSON"
  exit 1
fi

## read the secret
## NOTE: this sets the global variables $secret_exists, $secret_data, $secret_labels
read_kube_secret "$SECRET_NAME"

## if the secret already exists, verify it
if [[ "$secret_exists" == "true" ]]; then

  ## check if the secret has the required keys
  needs_update="false"
  for key_name in $(echo "$SECRET_KEYS" | jq -r '. // empty | keys[]'); do
    if [[ ! -v "secret_data[$key_name]" ]]; then
      echo "WARNING: secret '$SECRET_NAME' exists but is missing key '$key_name'"
      needs_update="true"
    fi
  done

  ## if an update is required, ensure the secret has a label indicating it was created by this script
  if [[ "$needs_update" == "true" ]]; then
    if [[ -v "secret_labels[$SECRET_LABEL]" ]]; then
      echo "INFO: secret '$SECRET_NAME' is missing keys, re-generating..."
      generate_kube_secret "$SECRET_NAME" "$SECRET_KEYS" "$SECRET_LABEL" "$SECRET_EXTRA_LABELS" "$SECRET_EXTRA_ANNOTATIONS" "true"
    else
      echo "ERROR: secret '$SECRET_NAME' does not have label '$SECRET_LABEL', so is not safe to update"
      exit 1
    fi
  else
    echo "INFO: secret '$SECRET_NAME' exists and has all required keys, skipping..."
  fi

## if the secret does not exist, create it
else
  echo "INFO: secret '$SECRET_NAME' does not exist, generating..."
  generate_kube_secret "$SECRET_NAME" "$SECRET_KEYS" "$SECRET_LABEL" "$SECRET_EXTRA_LABELS" "$SECRET_EXTRA_ANNOTATIONS" "false"
fi
