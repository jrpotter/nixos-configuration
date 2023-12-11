{ pkgs, stateVersion }:
let
  module = { config, modulesPath, lib, ... }:
    let
      cfg = config.virtualisation.digitalOceanImage;
    in
    {
      # This import must exist for all configurations to take effect the first
      # time launching a droplet. Refer to `config.system.build.toplevel` in
      # `make-disk-image.nix`.
      imports = [ ./configuration.nix ];

      options = {
        virtualisation.digitalOceanImage.diskSize = lib.mkOption {
          type = with lib.types; either (enum [ "auto" ]) int;
          default = "auto";
          example = 4096;
          description = lib.mdDoc ''
            Size of disk image. Unit is MB.
          '';
        };

        virtualisation.digitalOceanImage.configFile = lib.mkOption {
          type = with lib.types; nullOr path;
          default = null;
          description = lib.mdDoc ''
            A path to a configuration file which will be placed at
            `/etc/nixos/configuration.nix` and be used when switching
            to a new configuration. If set to `null`, a default
            configuration is used that imports
            `(modulesPath + "/virtualisation/digital-ocean-config.nix")`.
          '';
        };

        virtualisation.digitalOceanImage.compressionMethod = lib.mkOption {
          type = lib.types.enum [ "gzip" "bzip2" ];
          default = "gzip";
          example = "bzip2";
          description = lib.mdDoc ''
            Disk image compression method. Choose bzip2 to generate smaller
            images that take longer to generate but will consume less metered
            storage space on your Digital Ocean account.
          '';
        };
      };

      config = {
        system.build.digitalOceanImage = lib.mkForce (
          import ./make-disk-image.nix {
            name = "digital-ocean-image";
            format = "qcow2";
            postVM = let
              compress = {
                "gzip" = "${pkgs.gzip}/bin/gzip";
                "bzip2" = "${pkgs.bzip2}/bin/bzip2";
              }.${cfg.compressionMethod};
            in ''
              ${compress} $diskImage
            '';
            configFile = ./configuration.nix;
            swapSize = 1024;
            inherit (cfg) diskSize;
            inherit config lib pkgs;
          }
        );

        system.stateVersion = stateVersion;
      };
    };
in
  (pkgs.nixos module).digitalOceanImage
