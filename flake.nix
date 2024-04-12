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
            phobos = tapir.pkgs;
            thebe = tapir.pkgs;
          };
          nodeSpecialArgs = {
            deimos = {
              inherit (tapir) sops-nix;
            };
            framework = {
              inherit (tapir) home-manager;
            };
            phobos = {
              inherit (tapir) home-manager;
            };
            thebe = {
              inherit (tapir) sops-nix;
            };
            europa = {
              inherit (tapir) sops-nix;
            };
          };
        };

        deimos = {
          imports = [ ./hive/deimos ];
          deployment = {
            allowLocalDeployment = false;
            targetHost = "24.199.110.222";
          };
        };

        framework = {
          imports = [ ./hive/framework ];
          deployment = {
            allowLocalDeployment = true;
            targetHost = null;
          };
        };

        phobos = {
          imports = [ ./hive/phobos ];
          deployment = {
            allowLocalDeployment = true;
            targetHost = "144.126.218.252";
          };
        };

        thebe = {
          imports = [ ./hive/thebe ];
          deployment = {
            allowLocalDeployment = false;
            targetHost = "64.23.168.148";
          };
        };

        europa = {
          imports = [ ./hive/europa ];
          deployment = {
            allowLocalDeployment = false;
            targetHost = "147.182.255.90";
          };
        };
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
