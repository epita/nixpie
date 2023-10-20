#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

function getChangedPackages() {
  echoInfo "Evaluating packages..."
  nix_run nix-eval-jobs --check-cache-status --flake "${CI_PROJECT_DIR}#gitlabCiJobs.packages.x86_64-linux" | tee "${DIFF_DIR}/pkgs.jsonl" 1>&2
  jq -r '. | select(.isCached == false) | .attr' "${DIFF_DIR}/pkgs.jsonl" | xargs
}

echoInfo "Getting ready..."

mkdir -p "$DIFF_DIR"

print_defaults

echoInfo "Starting pipeline generation..."

changedPkgs=""
if [ -n "${ALL_PACKAGES:-}" ]; then
  changedPkgs="$(nix_run list-pkgs | xargs)"
else
  changedPkgs="$(getChangedPackages)"
fi

echoWarn "Packages to be rebuilt are: ${changedPkgs}"

echoInfo "Generating pipeline..."

for pkg in ${changedPkgs}; do
echoInfo "Generating jobs for package ${pkg}..."
cat <<EOF
${pkg}:build:
  extends:
    - .build
EOF

if isFork; then
cat <<EOF
    - .fork-default
EOF
fi

cat <<EOF
  script:
    - buildExpression=".#${pkg}"
    - nix -L build "\$buildExpression"
EOF

if ! isFork; then
cat <<EOF
    - nix store sign --recursive --key-file "\${NIX_CACHE_PRIV_KEY_FILE}" "\$buildExpression"
    - cat "\${AWS_NIX_CACHE_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix copy --to "s3://\${AWS_NIX_CACHE_BUCKET}?scheme=https&endpoint=\${AWS_NIX_CACHE_ENDPOINT}" "\$buildExpression"
EOF
fi
done

echoSuccess "All done!"
