{
  description = "Configuration of all remote NixOS machines.";

  inputs = {
    phobos = {
      url = "path:./phobos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, phobos, ... }:
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
