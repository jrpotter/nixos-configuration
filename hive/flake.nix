{
  description = "Configuration of all remote NixOS machines.";

  inputs = {
    phobos = {
      url = "path:./phobos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, phobos, ... }: {
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
      };

      # Remote machines
      phobos = phobos.nixosModules.default;
    };
  };
}
