#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

CHECKS_DIFF_DIR="${DIFF_DIR}/checks"
mkdir -p "${CHECKS_DIFF_DIR}"

print_defaults

echoInfo "Listing all checks..."
checks="$(nix_run list-checks | xargs)"
echoInfo "Checks found: ${checks}"

echoInfo "Generating pipeline..."

for check in ${checks}; do
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
