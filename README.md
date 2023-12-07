# nixos-configuration

The collection of publically visible nixos-configuration files used for my
personal machines. The only file not tracked is `hardware-configuration.nix`
since this is auto-generated when installinp NixOS.

## Overview

System-wide configuration is found in `configuration.nix`. User-specific
configuration is grouped within a top-level directory corresponding to the
user's username (as of now, just `jrpotter`). The top-level `flake.nix` file
links the system and user configurations together.
