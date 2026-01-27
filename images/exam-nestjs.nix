{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ../profiles/graphical
    ../profiles/exam
  ];

  netboot.enable = true;
  cri.sddm.title = "Exam NestJS";

  cri.xfce.enable = true;

  cri.packages = {
    pkgs = {
      dev.enable = true;
      js.enable = true;
      sql.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    nest-cli
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
      ];
    })
  ];
}
