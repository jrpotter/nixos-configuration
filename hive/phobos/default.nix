{ system, stateVersion, sops-nix, pkgs, lib, ... }:
let
  boardwise = builtins.getFlake
    "github:boardwise-gg/website/0c7d2b5932f06912034d8da3d13008cc53c50245";
  coach-scraper = builtins.getFlake
    "github:boardwise-gg/coach-scraper/58815d3ae5a69cac12436a01e77019a5ac5d16a7";
in
{
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    ../../digital-ocean/configuration.nix
    sops-nix.nixosModules.sops
  ];

  deployment.targetHost = "143.198.142.171";

  networking = {
    hostName = "phobos";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  programs.mosh.enable = true;

  services.openssh.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "boardwise" ];
    authentication = lib.mkOverride 10 ''
      # TYPE     DATABASE     USER     ADDRESS         METHOD
        local    all          all                      trust
        host     all          all      127.0.0.1/32    trust
    '';
  };

  systemd.services.boardwise = {
    enable = true;
    description = "BoardWise Server";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Environment = [
        "DATABASE_URL=ecto://postgres:postgres@localhost/boardwise"
      ];
      EnvironmentFile = "/run/secrets/SECRET_KEY_BASE";
      ExecStartPre = "${boardwise.packages.${system}.app}/bin/migrate";
      ExecStart = "${boardwise.packages.${system}.app}/bin/boardwise start";
      Restart = "on-failure";
    };
  };

  environment.systemPackages = [
    coach-scraper.packages.${system}.app
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.SECRET_KEY_BASE = {};
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jrpotter2112@gmail.com";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "www.boardwise.gg" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "boardwise.gg" ];
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:4000";
        };
      };
    };
  };

  system.stateVersion = stateVersion;
}
