# This module enables LUKS without requiring LVM or ZFS support. LVM in
# particular is known to have certain issues that we may want to avoid:
# https://superuser.com/questions/256061/lvm-and-cloning-hds
{ enableLVM ? false
, enableZFS ? false
}:

{ config, pkgs, lib, ... }:
let
  managedLuks = enableLVM || enableZFS;
  device-uuid = builtins.readFile ./config/device-uuid;
  cryptswap-uuid = (
    if managedLuks then "" else builtins.readFile ./config/cryptswap-uuid
  );
in
  # When working with LVM, we expect to create a swap partition manually during
  # NixOS installation. When working with ZFS, we currently don't bother. Either
  # way, this configuration should work.
  if managedLuks then
    {
      # https://www.adelbertc.com/installing-nixos/
      boot.initrd.luks.devices.luksroot = {
        device = "/dev/disk/by-uuid/" + device-uuid;
        allowDiscards = true;
      };
    }

  # Without LVM, we choose to generate a random `swap.key` file used for
  # decryption. This way we aren't required to enter our password twice. UUIDs
  # of our devices can be gotten by running: `lsblk -o name,uuid`.
  else
    {
      boot.loader.grub = { enableCryptodisk = true; };
      swapDevices = [
        {
          # UUID corresponding to the `cryptswap` LUKS container.
          device = "/dev/disk/by-uuid/" + cryptswap-uuid;
          encrypted = {
            enable = true;
            # The `swap.key` file should be generated when first installing
            # NixOS. This can be done by running
            # `cryptsetup luksFormat <SWAP partition> --key-file /mnt/root/swap.key`.
            keyFile = "/mnt-root/root/swap.key";
            # This is the label name set when running `cryptsetup luksOpen`. The
            # name can be anything we want.
            label = "cryptswap";
            # UUID of the physical swap partition.
            blkDev = "/dev/disk/by-uuid/" + device-uuid;
          };
        }
      ];
    }
