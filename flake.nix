{
  description = "Colmena hive configuration.";

  inputs = {
    # Stoat
    nixpkgs-23_05.url = "github:NixOS/nixpkgs/nixos-23.05";
    home-manager-23_05 = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-23_05";
    };

    # Tapir
    nixpkgs-23_11.url = "github:NixOS/nixpkgs/nixos-23.11";
    sops-nix-23_11 = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-23_11";
    };
  };

  outputs = {
    nixpkgs-23_05,
    home-manager-23_05,
    nixpkgs-23_11,
    sops-nix-23_11,
    ...
  }:
    let
      system = "x86_64-linux";
      stoat = {
        stateVersion = "23.05";
        pkgs = import nixpkgs-23_05 { inherit system; };
        home-manager = home-manager-23_05;
        sops-nix = null;
      };
      tapir = {
        stateVersion = "23.11";
        pkgs = import nixpkgs-23_11 { inherit system; };
        home-manager = null;
        sops-nix = sops-nix-23_11;
      };
    in
    {
      colmena = {
        meta = {
          nixpkgs = stoat.pkgs;
          specialArgs = { inherit system; };
          nodeNixpkgs = {
            framework = stoat.pkgs;
            phobos = tapir.pkgs;
            titan = stoat.pkgs;
          };
          nodeSpecialArgs = {
            framework = {
              inherit (stoat) stateVersion home-manager;
            };
            phobos = {
              inherit (tapir) stateVersion sops-nix;
            };
            titan = {
              inherit (stoat) stateVersion home-manager;
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

        phobos.imports = [ ./hive/phobos ];
        titan.imports = [ ./hive/titan ];
      };

      packages.${system}.digital-ocean = {
        stoat = import ./digital-ocean {
          inherit (stoat) pkgs stateVersion;
        };
        tapir = import ./digital-ocean {
          inherit (tapir) pkgs stateVersion;
        };
      };

      devShells.${system}.default =
        let
          pkgs = stoat.pkgs;
        in
          pkgs.mkShell {
            packages = with pkgs; [ ssh-to-age sops ];
          };
    };
}
