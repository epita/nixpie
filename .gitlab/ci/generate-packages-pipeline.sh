#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

PKGS_DIFF_DIR="${DIFF_DIR}/pkgs"
mkdir -p "${PKGS_DIFF_DIR}"

print_defaults

function getPkgDrvPath() {
  repo="${1}"
  pkg="${2}"

  path="${repo}#packages.x86_64-linux.${pkg}.drvPath"

  echo "${path}"
}

function didPkgChange() {
  pkg="${1}"
  diffFile="${PKGS_DIFF_DIR}/${pkg}"
  currentPkgDrvPath="$(getPkgDrvPath "${CI_PROJECT_DIR}" "${pkg}")"
  previousPkgDrvPath="$(getPkgDrvPath "git+${CI_PROJECT_URL}?ref=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" "${pkg}")"

  currentDrv="$(nix eval --raw "${currentPkgDrvPath}")"
  previousDrv="$(nix eval --raw "${previousPkgDrvPath}")" || return 0

  diffDrv "${previousDrv}" "${currentDrv}" "${diffFile}"
}

echoInfo "Listing all packages..."
pkgs="$(nix_run list-pkgs | xargs)"
echoInfo "Packages found: ${pkgs}"

changedPkgs=""

echoInfo "Starting pipeline generation..."

if [ -z "${CI_MERGE_REQUEST_IID:-}" ]; then
  echoWarn "Pipeline is not attached to a merge request."
  echoWarn "All packages will be rebuilt."
  changedPkgs="${pkgs}"
else
  echoWarn "Pipeline is attached to a merge request."
  echoWarn "Checking what packages we should rebuild..."
  for pkg in ${pkgs}; do
    echoInfo "Checking if package ${pkg} changed..."
    if didPkgChange "${pkg}"; then
      echoInfo "Package ${pkg} changed. Queue for rebuilding."
      changedPkgs="${changedPkgs:-} ${pkg}"
    else
      echoInfo "Package ${pkg} did not change. Not rebuilding."
    fi
  done
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
