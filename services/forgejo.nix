{ ... }:
{
  services = {
    forgejo = {
      enable = true;
      settings = {
        DEFAULT = {
          APP_NAME = "Git • Joshua Potter";
          RUN_MODE = "prod";
        };
        database = {
          # This is already set in /nixos/modules/services/misc/forgejo.nix.
          # Include here to be explicit. The database file is located at
          # `/var/lib/forgejo/data`.
          DB_TYPE = "sqlite3";
        };
        repository = {
          DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
          DISABLE_STARS = true;
        };
        other = {
          SHOW_FOOTER_VERSION = false;
          SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
        };
        server = {
          LANDING_PAGE = "/explore/repos";
          ROOT_URL = "https://git.jrpotter.com";
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        "service.explore" = {
          DISABLE_USERS_PAGE = true;
        };
        ui = {
          SHOW_USER_EMAIL = false;
        };
        "ui.meta" = {
          AUTHOR = "Git • Joshua Potter";
          DESCRIPTION = "Self-hosted git repositories.";
        };
      };
    };
    nginx.virtualHosts."git.jrpotter.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        recommendedProxySettings = true;
        proxyPass = "http://127.0.0.1:3000";
      };
    };
  };
}
