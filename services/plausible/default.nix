{ config, ... }:
{
  services = {
    plausible = {
      adminUser = {
        # activate is used to skip the email verification of the admin-user
        # that's automatically created by plausible. This is only supported if
        # postgresql is configured by the module. This is done by default, but
        # can be turned off with services.plausible.database.postgres.setup.
        activate = true;
        email = "jrpotter2112@gmail.com";
        passwordFile = "/run/secrets/PLAUSIBLE_ADMIN_PWD";
      };
      server = {
        baseUrl = "https://analytics.jrpotter.com";
        secretKeybaseFile = "/run/secrets/PLAUSIBLE_SECRET_KEY_BASE";
      };
    };
    nginx.virtualHosts."analytics.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}";
      };
    };
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets.PLAUSIBLE_ADMIN_PWD = {};
    secrets.PLAUSIBLE_SECRET_KEY_BASE = {};
  };
}
