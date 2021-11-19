#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

CHECKS_DIFF_DIR="${DIFF_DIR}/checks"
mkdir -p "${CHECKS_DIFF_DIR}"

print_defaults

function getCheckDrvPath() {
  repo="${1}"
  check="${2}"

  path="${repo}#checks.x86_64-linux.${check}.drvPath"

  echo "${path}"
}

function didCheckChange() {
  check="${1}"
  diffFile="${CHECKS_DIFF_DIR}/${check}"
  currentCheckDrvPath="$(getCheckDrvPath "${CI_PROJECT_DIR}" "${check}")"
  previousCheckDrvPath="$(getCheckDrvPath "git+${CI_PROJECT_URL}?ref=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" "${check}")"

  currentDrv="$(nix eval --raw "${currentCheckDrvPath}")"
  previousDrv="$(nix eval --raw "${previousCheckDrvPath}")" || return 0

  # We allow 31 lines of differences, which is the amount that changes when
  # only the commit SHA changes.
  diffDrv "${previousDrv}" "${currentDrv}" "${diffFile}" 31
}

echoInfo "Listing all checks..."
checks="$(nix_run list-checks | xargs)"
echoInfo "Checks found: ${checks}"

changedChecks=""

echoInfo "Starting pipeline generation..."

if [ -z "${CI_MERGE_REQUEST_IID:-}" ]; then
  echoWarn "Pipeline is not attached to a merge request."
  echoWarn "All checks will be rebuilt."
  changedChecks="${checks}"
else
  echoWarn "Pipeline is attached to a merge request."
  echoWarn "Checking what checks we should rebuild..."
  for check in ${checks}; do
    echoInfo "Checking if check ${check} changed..."
    if didCheckChange "${check}"; then
      echoInfo "Check ${check} changed. Queue for rebuilding."
      changedChecks="${changedChecks:-} ${check}"
    else
      echoInfo "Check ${check} did not change. Not rebuilding."
    fi
  done
fi

echoWarn "Checks to be rebuilt are: ${changedChecks}"

echoInfo "Generating pipeline..."

for check in ${changedChecks}; do
echoInfo "Generating job for check ${check}..."
cat <<EOF
${check}:
  extends:
    - .test
EOF
if isFork; then
cat <<EOF
    - .fork-default
EOF
fi
cat <<EOF
  script:
    - buildExpression=".#checks.x86_64-linux.${check}"
    - nix -L build "\$buildExpression"
  artifacts:
    paths:
      - result/*
    when: always
EOF
done

echoSuccess "All done!"
