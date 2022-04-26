{ config, pkgs, lib, ... }:
{
  # This line is only necessary when using ZFS. This must be unique to the
  # system. Can generate by running: `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "5bfd732b";
}
