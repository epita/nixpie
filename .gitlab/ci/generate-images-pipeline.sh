#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

function getChangedImages() {
  echoInfo "Evaluating images..."
  nix_run nix-eval-jobs --check-cache-status --flake "${CI_PROJECT_DIR}#gitlabCiJobs.images.x86_64-linux" | tee "${DIFF_DIR}/images.jsonl" 1>&2
  jq -r '. | select(.isCached == false or .error != null) | .attr' "${DIFF_DIR}/images.jsonl" | xargs
}

echoInfo "Getting ready..."

mkdir -p "$DIFF_DIR"

print_defaults

echoInfo "Starting pipeline generation..."

changedImages=""
if [ -n "${ALL_IMAGES:-}" ]; then
  changedImages="$(nix_run list-images | xargs)"
else
  changedImages="$(getChangedImages)"
fi

echoWarn "Images to be rebuilt are: ${changedImages}"

echoInfo "Generating pipeline..."

for image in ${changedImages}; do
echoInfo "Generating jobs for image ${image}..."
cat <<EOF
${image}:build:
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
    - buildExpression=".#nixosConfigurations.${image}.config.system.build.toplevel"
    - nix -L build "\$buildExpression"
EOF

if ! isFork; then
cat <<EOF
    - nix store sign --recursive --key-file "\${NIX_CACHE_PRIV_KEY_FILE}" "\$buildExpression"
    - cat "\${AWS_NIX_CACHE_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix copy --to "s3://\${AWS_NIX_CACHE_BUCKET}?scheme=https&endpoint=\${AWS_NIX_CACHE_ENDPOINT}" "\$buildExpression"

${image}:deploy:
  extends: .deploy
  needs:
    - ${image}:build
  variables:
    NIXPIE_LABEL_VERSION: "$(git rev-parse --short HEAD)"
  script:
    - buildExpression=".#nixosConfigurations.${image}.config.system.build.toplevel-netboot"
    - nix -L build --impure "\$buildExpression"
    - storePath="\$(readlink -f ./result)"
    - cat "\${AWS_PXE_IMAGES_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix_run awscli s3 --endpoint-url "\${AWS_PXE_IMAGES_ENDPOINT}" cp --acl public-read --recursive "\$storePath" "s3://\${AWS_PXE_IMAGES_BUCKET}"
    - rm -f ./result
    - nix store delete --impure "\$storePath"
EOF

if nix_run list-docker | grep "${image}" > /dev/null; then
cat <<EOF
${image}:docker:
  extends: .docker
  variables:
    NIXPIE_LABEL_VERSION: "$(git rev-parse --short HEAD)"
  needs:
    - ${image}:build
  variables:
    IMAGE: ${image}
EOF
fi
fi
done

echoSuccess "All done!"
