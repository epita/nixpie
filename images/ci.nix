{ lib
, nixpkgs
, nixpkgsMaster
, nixpkgsUnstable
, docker-nixpkgs
, pkgset
, self
, system
, ...
}@inputs:
with lib;
let
  inherit (pkgset) pkgs;

  mkCi = image: config: pkgs.writeText "${image}.json" (builtins.toJSON {
    stages = [
      "build"
      "deploy"
      "docker"
    ];

    before_script = [
      "mkdir -p ~/.aws"
      ''echo "[default]" > ~/.aws/config''
      # Fix nix errors about dirty tree
      "git switch $CI_COMMIT_REF_NAME"
      "git reset --hard $CI_COMMIT_SHA"
    ];

    "${image}-build" = {
      stage = "build";
      needs = [ ];
      tags = [ "nix" ];
      script = [
        ''export buildExpression=".#nixosConfigurations.${image}.config.system.build.toplevel"''
        ''nix -L build "$buildExpression"''
      ];
    };
    "${image}-deploy" = {
      stage = "deploy";
      needs = [ "${image}-build" ];
      tags = [ "nix" ];
      script = [
        ''export buildExpression=".#nixosConfigurations.${image}.config.system.build.toplevel-netboot"''
        ''nix -L build "$buildExpression"''
        ''nix profile install "nixpkgs#awscli"''
        ''cat "$AWS_PXE_IMAGES_CREDENTIALS_FILE" > ~/.aws/credentials''
        ''aws s3 --endpoint-url "$AWS_PXE_IMAGES_ENDPOINT" cp --acl public-read --recursive "$(readlink -f ./result)" "s3://$AWS_PXE_IMAGES_BUCKET"''
      ];
      when = "manual";
    };

    "${image}-docker" = {
      stage = "docker";
      needs = [ "${image}-build" ];
      tags = [ "nix" ];
      script = [
        ''export buildExpression=".#${image}-docker"''
        ''nix -L build "$buildExpression"''
        ''nix profile install "nixpkgs#skopeo"''
        ''skopeo login registry.cri.epita.fr --username $CI_REGISTRY_USER --password $CI_REGISTRY_PASSWORD''
        ''skopeo --insecure-policy copy "docker-archive:$(readlink -f ./result)" docker://$CI_REGISTRY_IMAGE/$IMAGE_NAME:$CI_COMMIT_SHA''
        ''skopeo --insecure-policy copy "docker-archive:$(readlink -f ./result)" docker://$CI_REGISTRY_IMAGE/$IMAGE_NAME:latest''
      ];
      when = "manual";
    };
  });
  allCI = (lib.mapAttrs
    (name: build: (mkCi name build.config))
    self.nixosConfigurations);
in
pkgs.linkFarm "ci" (lib.mapAttrsToList (name: ci: { name = "${name}.json"; path = ci; }) allCI)
