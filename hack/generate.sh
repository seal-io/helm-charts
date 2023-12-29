#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${ROOT_DIR}/hack/lib/init.sh"

function generate() {
  local target="$1"
  shift 1

  if [[ $# -gt 0 ]]; then
    for subdir in "$@"; do
      local path="${target}/${subdir}"
      seal::helm::docs "${path}"
      seal::helm::schema "${path}"
    done

    return 0
  fi

  seal::helm::docs "${target}"
  if [[ -d "${target}/charts" ]]; then
    local charts=()
    # shellcheck disable=SC2086
    IFS=" " read -r -a charts <<<"$(seal::util::find_subdirs ${target}/charts)"
    for chart in "${charts[@]}"; do
      seal::helm::schema "${target}/charts/${chart}"
    done
  fi
}

#
# main
#

seal::log::info "+++ GENERATE +++"

generate "${ROOT_DIR}" "$@"

seal::log::info "--- GENERATE ---"
