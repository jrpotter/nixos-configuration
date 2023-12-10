# nixos-configuration

The collection of publically visible nixos-configuration files used for all of
my NixOS machines. Deployment (both local and remote) is managed using
[colmena](https://github.com/zhaofengli/colmena). All machines can be found in
the `hive/flake.nix` file.

## Local Machines

My personal laptop configuration is reflected in the `hive/framework` directory
(named after the [framework](https://frame.work/) laptop I use). This flake
defines a [home-manager](https://nix-community.github.io/home-manager/)
configuration for a single user called `jrpotter`. We can apply a
`nixos-rebuild switch` by running:
```bash
$ cd hive
$ nix flake update  # If any changes were made to local machines.
$ colmena apply-local [--sudo]
```

## Remote Machines

Remote machines are hosted on [DigitalOcean](https://www.digitalocean.com/).
The custom image used by each droplet can be built using the top-level
`digital-ocean/23.11pre-git` flake. This image disables a root password
in favor of SSH. A droplet running this image will automatically pull in any
enabled SSH keys from your DigitalOcean account at creation time (so make sure
to include them when creating a new droplet).

### Secrets

Secrets are managed via [sops-nix](https://github.com/Mic92/sops-nix). The
top-level `.sops.yaml` configures the `age` keys used to encrypt all secrets.
Once configured, you can create/edit a new secrets file using `sops` like so:
```bash
$ nix-shell -p sops --run "sops <filename>"
```
Keep in mind that `sops-nix` supports YAML, JSON, INI, dotenv and binary at the
moment. What format is used is determined by `<filename>`'s extension.

#### Admins

To generate a new user-controlled key, you will need an ed25519 SSH key.
Generate one (if you do not already have one) by running:
```bash
$ ssh-keygen -t ed25519 -C "<email>"
```
You can then generate an `age` secret:
```bash
$ mkdir -p ~/.config/sops/age
$ nix-shell -p ssh-to-age --run \
    "ssh-to-age -private-key -i <ssh-file> > ~/.config/sops/age/keys.txt"
```
and find its corresponding public key:
```bash
$ nix-shell -p ssh-to-age --run "ssh-to-age < ~/.ssh/id_ed25519.pub"
```
This public key can then be written into the `.sops.yaml` file.

#### Servers

Each machine that needs to decrypt secret files will also need to be registered.
To do so, run:
```bash
$ nix-shell -p ssh-to-age --run 'ssh-keyscan <host> | ssh-to-age'
```
This will look for any SSH host ed25519 public keys and automatically run
through `ssh-to-age`. Include an appropriately top-level `keys` entry in
`.sops.yaml` before generating the secrets needed by the machine. Refer to
`phobos` for an example.

### Deployment

Like our local configurations, remote updates are managed by `colmena`.
`colmena` requires non-interactively connecting over the `ssh-ng` protocol
meaning you must add the appropriate private SSH key to an `ssh-agent` before
deploying:
```bash
$ eval $(ssh-agent -s)
$ ssh-add ~/.ssh/id_ed25519
```
Afterward you can run the following:
```bash
$ cd hive
$ nix flake update  # If any changes were made to remote machines.
$ colmena apply
```
