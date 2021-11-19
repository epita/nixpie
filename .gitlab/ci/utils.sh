echoErr() { >&2 echo -e "\e[1;31m[ERR] ${*}\e[0m" ; }
echoWarn() { >&2 echo -e "\e[1;33m[WARN] ${*}\e[0m" ; }
echoInfo() { >&2 echo -e "\e[1;34m[INFO] ${*}\e[0m" ; }
echoSuccess() { >&2 echo -e "\e[1;32m[SUCCESS] ${*}\e[0m" ; }

function print_defaults() {
echoInfo "Printing some default stuff..."
cat <<EOF
---

include:
  - template: Workflows/MergeRequest-Pipelines.gitlab-ci.yml
  - local: .gitlab/ci/templates.yml
EOF
}

function nix_run() {
  app="${1}"
  shift 1
  nix run "${CI_PROJECT_DIR}#${app}" -- "${@}"
}

function isFork() {
  [ -n "${CI_MERGE_REQUEST_SOURCE_PROJECT_URL:-}" ] && [ "${CI_MERGE_REQUEST_SOURCE_PROJECT_URL:-}" != "https://gitlab.cri.epita.fr/cri/infrastructure/nixpie" ]
}
