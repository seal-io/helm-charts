#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${ROOT_DIR}/hack/lib/init.sh"

function check_dirty() {
  [[ "${LINT_DIRTY:-false}" == "true" ]] || return 0

  if [[ -n "$(command -v git)" ]]; then
    if git_status=$(git status --porcelain 2>/dev/null) && [[ -n ${git_status} ]]; then
      seal::log::fatal "the git tree is dirty:\n$(git status --porcelain)"
    fi
  fi
}

function lint() {
  local target="$1"
  shift 1

  if [[ $# -gt 0 ]]; then
    for subdir in "$@"; do
      local path="${target}/${subdir}"
      seal::helm::lint "${path}"
    done

    return 0
  fi

  seal::helm::lint "${target}"
}

function after() {
  check_dirty
}

#
# main
#

seal::log::info "+++ LINT +++"

lint "${ROOT_DIR}" "$@"

after

seal::log::info "--- LINT ---"
