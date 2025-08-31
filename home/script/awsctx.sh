#!/bin/bash

function awsctx() {
  local ctx="$1"
  local CONFIG_DIR="$(_awsctx_get_directory config)"
  local CACHE_DIR="$(_awsctx_get_directory cache)"


  export AWSCTX="${ctx}"
  export AWS_SHARED_CREDENTIALS_FILE="${CACHE_DIR}/${ctx}.credentials"
  export AWS_CONFIG_FILE="${CONFIG_DIR}/${ctx}.config"
}

function _awsctx() {
  local CACHE_DIR="$(_awsctx_get_directory cache)"
  local current="${COMP_WORDS[${COMP_CWORD}]}"
  local credential

  test "${COMP_CWORD}" -gt 1 && return

  for credential in $(find "${CACHE_DIR}" -name "${current}*.credentials" 2>/dev/null); do
    credential="${credential##*/}"
    COMPREPLY+=("${credential%.credentials}")
  done
}

function _awsctx_get_directory() {
  local type="$1"

  case "$(uname -s)" in
    Darwin*)
      [ -z "${XDG_CONFIG_HOME}" ] && local XDG_CONFIG_HOME="${HOME}/Library/Application Support"
      [ -z "${XDG_CACHE_HOME}" ] && local XDG_CACHE_HOME="${HOME}/Library/Caches"
      ;;
    Linux*)
      [ -z "${XDG_CONFIG_HOME}" ] && local XDG_CONFIG_HOME="${HOME}/.config"
      [ -z "${XDG_CACHE_HOME}" ] && local XDG_CACHE_HOME="${HOME}/.cache"
      ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac

  local CONFIG_DIR="${XDG_CONFIG_HOME}/awsctx"
  local CACHE_DIR="${XDG_CACHE_HOME}/awsctx"

  case "${type}" in
    config)
      echo "${CONFIG_DIR}"
      ;;
    cache)
      echo "${CACHE_DIR}"
      ;;
    *)
      echo "Unsupported type: ${type}"
      exit 1
      ;;
  esac
}

complete -F _awsctx awsctx
