{
  description = "Phobos machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = { nixpkgs, ... }: {
    nixosModules.default = { modulesPath, lib, ... }: {
      imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
        (modulesPath + "/virtualisation/digital-ocean-config.nix")
      ];

      deployment.targetHost = "146.190.127.180";

      networking.hostName = "phobos";

      system.stateVersion = "23.11";
    };
  };
}
