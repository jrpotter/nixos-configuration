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

Remote machines are hosted on [DigitalOcean](https://www.digitalocean.com/).
The custom image used by each droplet can be built using the top-level
`digital-ocean` flake. This image disables a root password in favor of SSH.
A droplet running this image will automatically pull in any enabled SSH keys
from your DigitalOcean account at creation time.

Deployment is managed using [colmena](https://github.com/zhaofengli/colmena).
To deploy, run the following:
```bash
$ cd infra
$ nix flake update  # If any machine changes were made.
$ colmena apply
```
Note that colmena requires non-interactivity. If you haven't done so already,
you'll likely need to add the private SSH key corresponding to the public one
uploaded to DigitalOcean to your SSH agent. Do so by running:
```bash
$ eval $(ssh-agent -s)
$ ssh-add <ssh-file>
```
