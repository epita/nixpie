#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

IMAGES_DIFF_DIR="${DIFF_DIR}/images"
mkdir -p "${IMAGES_DIFF_DIR}"

print_defaults

function getImageDrvPath() {
  repo="${1}"
  image="${2}"

  path="${repo}#nixosConfigurations.${image}.config.system.build.toplevel.drvPath"

  echo "${path}"
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

echoInfo "Listing all images..."
images="$(nix_run list-images | xargs)"
echoInfo "Images found: ${images}"

changedImages=""

echoInfo "Starting pipeline generation..."

if [ -z "${CI_MERGE_REQUEST_IID:-}" ]; then
  echoWarn "Pipeline is not attached to a merge request."
  echoWarn "All images will be rebuilt."
  changedImages="${images}"
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
fi

echoWarn "Images to be rebuilt are: ${changedImages}"

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

echoSuccess "All done!"
