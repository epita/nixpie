#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

DIFF_DIR="${CI_PROJECT_DIR}/diffs"
IMAGES_DIFF_DIR="${DIFF_DIR}/images"
PKGS_DIFF_DIR="${DIFF_DIR}/pkgs"
mkdir -p "${IMAGES_DIFF_DIR}" "${PKGS_DIFF_DIR}"

print_defaults

cat <<EOF
dummy:
  stage: qa
  tags: []
  script:
    - echo I am only here so the pipeline does not fail when nothing needs rebuilding.
EOF

function getImageDrvPath() {
  repo="${1}"
  image="${2}"

  path="${repo}#nixosConfigurations.${image}.config.system.build.toplevel.drvPath"

  echo "${path}"
}

function getPkgDrvPath() {
  repo="${1}"
  pkg="${2}"

  path="${repo}#packages.x86_64-linux.${pkg}.drvPath"

  echo "${path}"
}

function nix_diff() {
  nix_run nix-diff --line-oriented "${@}"
}

function diffDrv() {
  drvSrc="${1}"
  drvDst="${2}"
  diffFile="${3}"
  allowedDifferences="${4:-0}"

  # We run multiple times to get color in output. nix-diff is pretty
  # inexpensive so let's not care too much about this
  nix_diff "${drvSrc}" "${drvDst}" > "${diffFile}"
  nix_diff --environment "${drvSrc}" "${drvDst}" > "${diffFile}.env"

  if [ "$(wc -l < "${diffFile}")" -gt "${allowedDifferences}" ]; then
    nix_diff --color always "${drvSrc}" "${drvDst}" >&2
    return 0
  else
    return 1
  fi
}

function didImageChange() {
  image="${1}"
  diffFile="${IMAGES_DIFF_DIR}/${image}"
  currentImageDrvPath="$(getImageDrvPath "${CI_PROJECT_DIR}" "${image}")"
  previousImageDrvPath="$(getImageDrvPath "git+${CI_PROJECT_URL}?ref=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" "${image}")"

  currentDrv="$(nix eval --raw "${currentImageDrvPath}")"
  previousDrv="$(nix eval --raw "${previousImageDrvPath}")"

  # We allow 54 lines of differences, which is the amount that changes when
  # only the commit SHA changes.
  diffDrv "${previousDrv}" "${currentDrv}" "${diffFile}" 54
}

function didPkgChange() {
  pkg="${1}"
  diffFile="${PKGS_DIFF_DIR}/${pkg}"
  currentPkgDrvPath="$(getPkgDrvPath "${CI_PROJECT_DIR}" "${pkg}")"
  previousPkgDrvPath="$(getPkgDrvPath "git+${CI_PROJECT_URL}?ref=${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" "${pkg}")"

  currentDrv="$(nix eval --raw "${currentPkgDrvPath}")"
  previousDrv="$(nix eval --raw "${previousPkgDrvPath}")"

  diffDrv "${previousDrv}" "${currentDrv}" "${diffFile}"
}

echoInfo "Listing all images..."
images="$(nix_run list-images | xargs)"
echoInfo "Images found: ${images}"

echoInfo "Listing all packages..."
pkgs="$(nix_run list-pkgs | xargs)"
echoInfo "Packages found: ${pkgs}"

changedImages=""
changedPkgs=""

echoInfo "Starting pipeline generation..."

if [ -z "${CI_MERGE_REQUEST_IID:-}" ]; then
  echoWarn "Pipeline is not attached to a merge request."
  echoWarn "All images and packages will be rebuilt."
  changedImages="${images}"
  changedPkgs="${pkgs}"
else
  echoWarn "Pipeline is attached to a merge request."
  echoWarn "Checking what images we should rebuild..."
  for image in ${images}; do
    echoInfo "Checking if image ${image} changed..."
    if didImageChange "${image}"; then
      echoInfo "Image ${image} changed. Queued for rebuilding."
      changedImages="${changedImages:-} ${image}"
    else
      echoInfo "Image ${image} did not change. Not rebuilding."
    fi
  done

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

echoWarn "Images to be rebuilt are: ${changedImages}"
echoWarn "Packages to be rebuilt are: ${changedPkgs}"

echoInfo "Generating pipeline..."

for image in ${changedImages}; do
echoInfo "Generating jobs for image ${image}..."
cat <<EOF
generate ${image} image pipeline:
  extends: .generate
EOF
if isFork; then
cat <<EOF
  tags: []
EOF
fi
cat <<EOF
  script:
    - .gitlab/ci/generate-image-pipeline.sh | tee pipeline.yml
  variables:
    IMAGE: ${image}
${image} image pipeline:
  extends: .trigger
  needs:
    - generate ${image} image pipeline
  trigger:
    include:
      - job: generate ${image} image pipeline
        artifact: pipeline.yml
EOF
done

for pkg in ${changedPkgs}; do
echoInfo "Generating jobs for package ${pkg}..."
cat <<EOF
generate ${pkg} package pipeline:
  extends: .generate
EOF
if isFork; then
cat <<EOF
  tags: []
EOF
fi
cat <<EOF
  script:
    - .gitlab/ci/generate-package-pipeline.sh | tee pipeline.yml
  variables:
    PACKAGE: ${pkg}
${pkg} package pipeline:
  extends: .trigger
  needs:
    - generate ${pkg} package pipeline
  trigger:
    include:
      - job: generate ${pkg} package pipeline
        artifact: pipeline.yml
EOF
done

echoSuccess "All done!"
