{
  description = "A NixOS image builder for DigitalOcean.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      module = {
        imports = [
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
        ];

        system.stateVersion = "23.11";
      };
    in {
      packages.${system}.default = (pkgs.nixos module).digitalOceanImage;
    };
}
