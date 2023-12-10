{ pkgs, stateVersion }:
let
  module = { modulesPath, ... }: {
    imports = [
      (modulesPath + "/virtualisation/digital-ocean-image.nix")
    ];

    system.stateVersion = stateVersion;
  };
in
  (pkgs.nixos module).digitalOceanImage
