#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${ROOT_DIR}/hack/lib/init.sh"

TEST_DIR="${ROOT_DIR}/.dist/test"
mkdir -p "${TEST_DIR}"

function test() {
  local target="$1"
  shift 1

  if [[ $# -gt 0 ]]; then
    for subdir in "$@"; do
      local path="${target}/${subdir}"
      seal::helm::test "${path}"
    done

    return 0
  fi

  seal::helm::test "${target}"
}

#
# main
#

seal::log::info "+++ TEST +++"

test "${ROOT_DIR}" "$@"

seal::log::info "--- TEST ---"
