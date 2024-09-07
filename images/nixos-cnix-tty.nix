{ config, lib, ... }:

{
  imports = [ ];

  # Define the shell script to generate the static /etc/issue file
  environment.etc."issue".text = lib.strings.concatStrings [
    (builtins.readFile ./tty-issue)
    "\n${config.system.nixos.distroName} ${config.system.nixos.label} (\\m) - \\l\n\n"
  ];
}
