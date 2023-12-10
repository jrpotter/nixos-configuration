{
  description = "Colmena hive configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    framework.url = "path:./hive/framework";
    phobos.url = "path:./hive/phobos";
    titan.url = "path:./hive/titan";
  };

  outputs = { nixpkgs, framework, phobos, titan, ... }:
    let
      system = "x86_64-linux";
      jrpotter = import ./users/jrpotter;
    in
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs { inherit system; };
          specialArgs = { inherit system; };
          nodeSpecialArgs = {
            framework = { inherit jrpotter; };
            titan = { inherit jrpotter; };
          };
        };

        # Local machines. Deploy using `colmena apply-local [--sudo]`

        framework = {
          imports = [ framework.nixosModules.default ];
          deployment = {
            allowLocalDeployment = true;
            targetHost = null;  # Disable SSH deployment.
          };
        };

        # Remote machines. Deploy using `colmena apply`

        phobos = phobos.nixosModules.default;
        titan = titan.nixosModules.default;
      };
    };
}
