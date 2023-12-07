{
  description = "Configuration of all remote NixOS machines.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, ... }:
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        # Remote machines
        phobos = (import ./phobos.nix);
      };
    };
}
