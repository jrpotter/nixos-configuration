# nixos-configuration

The collection of publically visible nixos-configuration files used for my
NixOS fleet.

## Desktop

My personal desktop configuration is reflected in the top-level `desktop`
directory. The only file not tracked is `hardware-configuration.nix` since this
is auto-generated when installing NixOS.

The system-wide configuration is found in `configuration.nix`. User-specific
configurations are grouped within a directory specific to each user. As of now,
this is just `jrpotter`. The `flake.nix` file links the system and user
configurations together.

## Remotes

Remote machines are handled on [DigitalOcean](https://www.digitalocean.com/),
deployed using [colmena](https://github.com/zhaofengli/colmena). The custom
image used by each droplet can be built using the top-level `digital-ocean`
flake.
