#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Helm variables helpers. These functions need the
# following variables:
#
# HELM_CHART_TESTING_VERSION  -  The Helm Chart Testing version, default is v3.10.1.
#    HELM_SCHEMA_GEN_VERSION  -  The Helm Schema Gen version, default is 0.0.4.
#          HELM_DOCS_VERSION  -  The Helm Docs version, default is v1.12.0.
#               HELM_VERSION  -  The Helm version, default is v3.13.3.

helm_chart_testing_version=${HELM_CHART_TESTING_VERSION:-"v3.10.1"}
helm_schema_gen_version=${HELM_SCHEMA_GEN_VERSION:-"0.0.10"}
helm_docs_version=${HELM_DOCS_VERSION:-"v1.12.0"}
helm_version=${HELM_VERSION:-"v3.13.3"}

function seal::helm::docs::install() {
  GOBIN="${ROOT_DIR}/.sbin" go install github.com/norwoodj/helm-docs/cmd/helm-docs@"${helm_docs_version}"
}

function seal::helm::docs::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::helm::docs::bin))" ]]; then
    return 0
  fi

  seal::log::info "installing helm-docs ${helm_docs_version}"
  if seal::helm::docs::install; then
    return 0
  fi
  seal::log::error "no helm-docs available"
  return 1
}

function seal::helm::docs::bin() {
  local bin="helm-docs"
  if [[ -f "${ROOT_DIR}/.sbin/helm-docs" ]]; then
    bin="${ROOT_DIR}/.sbin/helm-docs"
  fi
  echo -n "${bin}"
}

function seal::helm::helm::install() {
  local os
  os=$(seal::util::get_os)
  local arch
  arch=$(seal::util::get_arch)

  curl --retry 3 --retry-all-errors --retry-delay 3 \
    -o /tmp/helm.tar.gz \
    -sSfL "https://get.helm.sh/helm-${helm_version}-${os}-${arch}.tar.gz"

  tar -zxvf /tmp/helm.tar.gz \
    --directory "${ROOT_DIR}/.sbin" \
    --no-same-owner \
    --strip-components 1 \
    "${os}-${arch}/helm"
  chmod a+x "${ROOT_DIR}/.sbin/helm"
}

function seal::helm::helm::validate() {
  # shellcheck disable=SC2046
  if [[ -n "$(command -v $(seal::helm::helm::bin))" ]]; then
    if [[ $($(seal::helm::helm::bin) version --template="{{ .Version }}" 2>/dev/null | head -n 1) == "${helm_version}" ]]; then
      return 0
    fi
  fi

  seal::log::info "installing helm ${helm_version}"
  if seal::helm::helm::install; then
    seal::log::info "helm $($(seal::helm::helm::bin) version --template="{{ .Version }}" 2>/dev/null | head -n 1)"
    return 0
  fi
  seal::log::error "no helm available"
  return 1
}

function seal::helm::helm::bin() {
  local bin="helm"
  if [[ -f "${ROOT_DIR}/.sbin/helm" ]]; then
    bin="${ROOT_DIR}/.sbin/helm"
  fi
  echo -n "${bin}"
}

function seal::helm::plugin::schema_gen::validate() {
  if ! seal::helm::helm::validate; then
    seal::log::error "cannot execute helm as it hasn't installed"
    return 1
  fi

  local version
  version=$($(seal::helm::helm::bin) plugin list | grep schema-gen | sed 's/\t/ /g' | cut -d" " -f2)
  if [[ "${version}" == "${helm_schema_gen_version}" ]]; then
    return 0
  fi

  if [[ -n "${version}" ]]; then
    seal::log::info "updating helm-schema-gen ${version} to ${helm_schema_gen_version}"
    $(seal::helm::helm::bin) plugin update schema-gen --version "${helm_schema_gen_version}"
  else
    seal::log::info "installing helm-schema-gen ${helm_schema_gen_version}"
    $(seal::helm::helm::bin) plugin install https://github.com/knechtionscoding/helm-schema-gen --version "${helm_schema_gen_version}"
  fi
}

function seal::helm::lint() {
  local target="$1"
  shift 1

  local lint_command=("ct" "lint" "--config=lint.yaml" "--debug")
  if [[ ${target} != "${ROOT_DIR}" ]]; then
    lint_command+=("--charts=${target#"${ROOT_DIR}/"}")
  else
    lint_command+=("--all")
  fi

  seal::log::info "linting ${target} ..."
  docker run \
    --rm \
    --network host \
    --volume "${ROOT_DIR}:/workspace" \
    --workdir /workspace \
    quay.io/helmpack/chart-testing:"${helm_chart_testing_version}" \
    "${lint_command[@]}"
}

function seal::helm::test() {
  local target="$1"
  shift 1

  local test_command=("ct" "install" "--config=lint.yaml")
  if [[ ${target} != "${ROOT_DIR}" ]]; then
    test_command+=("--charts=${target#"${ROOT_DIR}/"}")
  else
    test_command+=("--all")
  fi

  seal::log::info "testing ${target} ..."
  docker run \
    --rm \
    --network host \
    --volume "${ROOT_DIR}:/workspace" \
    --volume "${HOME}"/.kube/config:/root/.kube/config:ro \
    --workdir /workspace \
    quay.io/helmpack/chart-testing:"${helm_chart_testing_version}" \
    "${test_command[@]}"
}

function seal::helm::docs() {
  if ! seal::helm::docs::validate; then
    seal::log::error "cannot execute helm-docs as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  seal::log::info "docing ${target} ..."
  $(seal::helm::docs::bin) \
    --log-level=error \
    --sort-values-order="file" \
    --document-dependency-values=true \
    --template-files=README.md.gotmpl \
    --chart-search-root="${target}"
}

function seal::helm::pull() {
  if ! seal::helm::helm::validate; then
    seal::log::error "cannot execute helm as it hasn't installed"
    return 1
  fi

  local target="$1"
  local destination="$2"

  local args=()
  if [[ "${target%%:*}" == "${target%:*}" ]]; then
    args=("${target}")
  else
    args=(
      "${target%:*}"
      "--version=${target##*:}"
    )
    case "${target%%:*}" in
    oci)
      if [[ -f "${destination}/$(basename "${target}" | sed 's/:/-/g').tgz" ]]; then
        return 0
      fi
      ;;
    esac
  fi
  args+=("--destination=${destination}")

  mkdir -p "${destination}"
  seal::log::info "pulling ${target} chart ..."
  $(seal::helm::helm::bin) pull "${args[@]}"
}

function seal::helm::schema() {
  if ! seal::helm::plugin::schema_gen::validate; then
    seal::log::error "cannot execute helm-schema-gen as it hasn't installed"
    return 1
  fi

  local target="$1"
  shift 1

  seal::log::info "scheming ${target} ..."
  $(seal::helm::helm::bin) schema-gen "${target}/values.yaml" >"${target}/values.schema.json"
}
