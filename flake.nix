{
  description = "Colmena hive configuration.";

  inputs = {
    nixpkgs-23_11 = {
      url = "github:NixOS/nixpkgs/nixos-23.11";
    };
    home-manager-23_11 = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };
    sops-nix-23_11 = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };
  };

  outputs = { nixpkgs-23_11, home-manager-23_11, sops-nix-23_11, ... }:
    let
      system = "x86_64-linux";
      tapir = {
        stateVersion = "23.11";
        pkgs = import nixpkgs-23_11 { inherit system; };
        home-manager = home-manager-23_11;
        sops-nix = sops-nix-23_11;
      };
    in
    {
      colmena = {
        meta = {
          nixpkgs = tapir.pkgs;
          specialArgs = { inherit system; };
          nodeNixpkgs = {
            framework = tapir.pkgs;
            deimos = tapir.pkgs;
            thebe = tapir.pkgs;
          };
          nodeSpecialArgs = {
            framework = {
              inherit (tapir) home-manager;
            };
            deimos = {
              inherit (tapir) sops-nix;
            };
            thebe = {
              inherit (tapir) sops-nix;
            };
          };
        };

        # Local machines. Deploy using `colmena apply-local [--sudo]`

        framework = {
          imports = [ ./hive/framework ];
          deployment = {
            allowLocalDeployment = true;
            targetHost = null;  # Disable SSH deployment.
          };
        };

        # Remote machines. Deploy using `colmena apply`

        deimos.imports = [ ./hive/deimos ];
        thebe.imports = [ ./hive/thebe ];
      };

      packages.${system}.digital-ocean = {
        tapir = import ./digital-ocean {
          inherit (tapir) pkgs stateVersion;
        };
      };

      devShells.${system}.default =
        let
          pkgs = tapir.pkgs;
        in
          pkgs.mkShell {
            packages = with pkgs; [ ssh-to-age sops ];
          };
    };
}
