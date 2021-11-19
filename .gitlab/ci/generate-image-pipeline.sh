#!/usr/bin/env bash

set -euo pipefail

source "${CI_PROJECT_DIR}/.gitlab/ci/utils.sh"

echoInfo "Getting ready..."

print_defaults

if isFork; then
  echoWarn "This is a fork. Not generating deploy jobs and tweaking some options to make the jobs run."
fi

echoInfo "Generating jobs..."
cat <<EOF
build:
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
    - buildExpression=".#nixosConfigurations.${IMAGE}.config.system.build.toplevel"
    - nix -L build "\$buildExpression"
EOF

if ! isFork; then
cat <<EOF
    - nix store sign --recursive --key-file "\${NIX_CACHE_PRIV_KEY_FILE}" "\$buildExpression"
    - cat "\${AWS_NIX_CACHE_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix copy --to "s3://\${AWS_NIX_CACHE_BUCKET}?scheme=https&endpoint=\${AWS_NIX_CACHE_ENDPOINT}" "\$buildExpression"

deploy:
  extends: .deploy
  script:
    - buildExpression=".#nixosConfigurations.${IMAGE}.config.system.build.toplevel-netboot"
    - nix -L build "\$buildExpression"
    - cat "\${AWS_PXE_IMAGES_CREDENTIALS_FILE}" > ~/.aws/credentials
    - nix_run awscli s3 --endpoint-url "\${AWS_PXE_IMAGES_ENDPOINT}" cp --acl public-read --recursive "\$(readlink -f ./result)" "s3://\${AWS_PXE_IMAGES_BUCKET}"

docker:
  extends: .docker
  variables:
    IMAGE: ${IMAGE}
EOF
fi

echoSuccess "All done!"
