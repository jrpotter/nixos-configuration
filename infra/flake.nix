{
  description = "Configuration of all remote NixOS machines.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    phobos = {
      url = "path:./phobos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, phobos, sops-nix, ... }:
    let
      system = "x86_64-linux";
    in
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            inherit system;
          };
          specialArgs = { inherit system; };
        };

        # Remote machines
        phobos = phobos.nixosModules.default;
      };
    };
}
