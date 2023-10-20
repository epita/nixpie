#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

function getChangedChecks() {
  echoInfo "Evaluating checks..."
  nix_run nix-eval-jobs --check-cache-status --flake "${CI_PROJECT_DIR}#gitlabCiJobs.checks.x86_64-linux" | tee "${DIFF_DIR}/checks.jsonl" 1>&2
  jq -r '. | select(.isCached == false) | .attr' "${DIFF_DIR}/checks.jsonl" | xargs
}

echoInfo "Getting ready..."

mkdir -p "$DIFF_DIR"

print_defaults


echoInfo "Starting pipeline generation..."

changedChecks=""
if [ -n "${ALL_CHECKS:-}" ]; then
  changedChecks="$(nix_run list-checks | xargs)"
else
  changedChecks="$(getChangedChecks)"
fi

echoWarn "Tests to be rebuilt are: ${changedChecks}"

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
EOF

if ! isFork; then
cat <<EOF
    - nix store sign --recursive --key-file "\${NIX_CACHE_PRIV_KEY_FILE}" "\$buildExpression"
    - cat "\${AWS_NIX_CACHE_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix copy --to "s3://\${AWS_NIX_CACHE_BUCKET}?scheme=https&endpoint=\${AWS_NIX_CACHE_ENDPOINT}" "\$buildExpression"
EOF
fi

cat <<EOF
  artifacts:
    paths:
      - result/*
    when: always
EOF
done

echoSuccess "All done!"
