{ pkgs
, lib
, name ? "nixos-disk-image"
, # The NixOS configuration to be installed onto the disk image.
  config
, # The size of the disk, in megabytes. If "auto", the size is calculated based
  # on the contents copied to it and `extraSize` is taken into account.
  diskSize ? "auto"
, # Extra disk space, in megabytes. Added to the image if diskSize "auto" is
  # used.
  extraSize ? 512
, # Swap space, in megabytes. Addeded to the image unless set to null.
  swapSize ? 512
, # The unique identifier for the swap partition.
  swapUUID ? "44444444-4444-4444-8888-888888888887"
, # The label given to the swap partition.
  swapLabel ? "swap"
, # Whether to invoke `switch-to-configuration boot` during image creation.
  installBootLoader ? true
, # The filesystem label.
  label ? "nixos"
, # The initial NixOS configuration file set at `/etc/nixos/configuration.nix`.
  configFile ? null
, # Disk image format, one of qcow2, qcow2-compressed, vdi, vpc, raw.
  format ? "raw"
, # The root Filesystem Unique Identifier.
  rootFSUID ? "F222513B-DED1-49FA-B591-20CE86A2FE7F"
, # Whether a nix channel based on the current source tree should be
  # made available inside the image. Useful for interactive use of nix
  # utils, but changes the hash of the image when the sources are
  # updated.
  copyChannel ? true
, # Shell code executed after the VM has finished.
  postVM ? ""
, # Guest memory size
  memSize ? 1024
}:
let
  format' = if format == "qcow2-compressed" then "qcow2" else format;

  compress = lib.optionalString (format == "qcow2-compressed") "-c";

  filename = "nixos." + {
    qcow2 = "qcow2";
    vdi   = "vdi";
    vpc   = "vhd";
    raw   = "img";
  }.${format'} or format';

  swapPartition = "1";
  rootPartition = "2";
  swapEnd = toString (1 + swapSize);

  nixpkgs = lib.cleanSource pkgs.path;

  # FIXME: merge with channel.nix / make-channel.nix.
  channelSources = pkgs.runCommand "nixos-${config.system.nixos.version}" {} ''
    mkdir -p $out
    cp -prd ${nixpkgs.outPath} $out/nixos
    chmod -R u+w $out/nixos
    if [ ! -e $out/nixos/nixpkgs ]; then
      ln -s . $out/nixos/nixpkgs
    fi
    rm -rf $out/nixos/.git
    echo -n ${config.system.nixos.versionSuffix} > $out/nixos/.version-suffix
  '';

  binPath = lib.makeBinPath (with pkgs; [
    rsync
    util-linux
    parted
    e2fsprogs
    lkl
    config.system.build.nixos-install
    config.system.build.nixos-enter
    nix
    systemdMinimal
    gptfdisk
  ] ++ stdenv.initialPath);

  closureInfo = pkgs.closureInfo {
    rootPaths = [ config.system.build.toplevel ] ++
      lib.optional copyChannel channelSources;
  };

  # ext4fs block size (not block device sector size)
  blockSize = toString (4 * 1024);

  prepareImage = ''
    export PATH=${binPath}

    # Yes, mkfs.ext4 takes different units in different contexts. Fun.
    sectorsToKilobytes() {
      echo $(( ( "$1" * 512 ) / 1024 ))
    }

    sectorsToBytes() {
      echo $(( "$1" * 512  ))
    }

    # Given lines of numbers, adds them together
    sum_lines() {
      local acc=0
      while read -r number; do
        acc=$((acc+number))
      done
      echo "$acc"
    }

    mebibyte=$(( 1024 * 1024 ))

    # Approximative percentage of reserved space in an ext4 fs over 512MiB.
    # 0.05208587646484375 × 1000, integer part: 52
    compute_fudge() {
      echo $(( $1 * 52 / 1000 ))
    }

    mkdir $out

    root="$PWD/root"
    mkdir -p $root

    export HOME=$TMPDIR

    # Provide a Nix database so that nixos-install can copy closures.
    export NIX_STATE_DIR=$TMPDIR/state
    nix-store --load-db < ${closureInfo}/registration

    chmod 755 "$TMPDIR"
    echo "running nixos-install..."
    nixos-install --root $root --no-bootloader --no-root-passwd \
      --system ${config.system.build.toplevel} \
      ${if copyChannel then "--channel ${channelSources}" else "--no-channel-copy"} \
      --substituters ""

    diskImage=nixos.raw

    ${if diskSize == "auto" then ''
      # Add the 1MiB aligned reserved space (includes MBR)
      reservedSpace=$(( mebibyte ))

      swapSpace=$((
        $(numfmt --from=iec '${toString swapSize}M') + reservedSpace
      ))

      extraSpace=$((
        $(numfmt --from=iec '${toString extraSize}M') + reservedSpace
      ))

      # Compute required space in filesystem blocks
      diskUsage=$(
        find . ! -type d -print0 |
        du --files0-from=- --apparent-size --block-size "${blockSize}" |
        cut -f1 |
        sum_lines
      )
      # Each inode takes space!
      numInodes=$(find . | wc -l)
      # Convert to bytes, inodes take two blocks each!
      diskUsage=$(( (diskUsage + 2 * numInodes) * ${blockSize} ))
      # Then increase the required space to account for the reserved blocks.
      fudge=$(compute_fudge $diskUsage)
      requiredFilesystemSpace=$(( diskUsage + fudge ))

      diskSize=$(( requiredFilesystemSpace + swapSpace + extraSpace ))

      # Round up to the nearest mebibyte. This ensures whole 512 bytes sector
      # sizes in the disk image and helps towards aligning partitions optimally.
      if (( diskSize % mebibyte )); then
        diskSize=$(( ( diskSize / mebibyte + 1) * mebibyte ))
      fi

      truncate -s "$diskSize" $diskImage

      printf "Automatic disk size...\n"
      printf "  Closure space use: %d bytes\n" $diskUsage
      printf "  fudge: %d bytes\n" $fudge
      printf "  Filesystem size needed: %d bytes\n" $requiredFilesystemSpace
      printf "  Swap space: %d bytes\n" $swapSpace
      printf "  Extra space: %d bytes\n" $extraSpace
      printf "  Disk image size: %d bytes\n" $diskSize
    '' else ''
      truncate -s ${toString diskSize}M $diskImage
    ''}

    parted --script $diskImage -- mklabel msdos
    parted --script $diskImage -- \
      mkpart primary linux-swap 1MiB ${swapEnd}MiB \
      mkpart primary ext4 ${swapEnd}MiB -1

    # Get start & length of the root partition in sectors to $START and
    # $SECTORS.
    eval $(partx $diskImage -o START,SECTORS --nr ${rootPartition} --pairs)

    mkfs.ext4 -b ${blockSize} -F -L ${label} $diskImage -E \
      offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K

    echo "copying staging root to image..."
    cptofs -p -P ${rootPartition} -t ext4 -i $diskImage $root/* / ||
      (echo >&2 "ERROR: cptofs failed. diskSize might be too small for closure."; exit 1)
  '';

  moveOrConvertImage = ''
    ${if format' == "raw" then "mv $diskImage $out/${filename}" else ''
      ${pkgs.qemu-utils}/bin/qemu-img convert -f raw -O ${format'} ${compress} \
        $diskImage $out/${filename}
    ''}
    diskImage=$out/${filename}
  '';

  buildImage = pkgs.vmTools.runInLinuxVM (
    pkgs.runCommand name {
      preVM = prepareImage;
      buildInputs = with pkgs; [ util-linux e2fsprogs dosfstools ];
      postVM = moveOrConvertImage + postVM;
      inherit memSize;
    } ''
      export PATH=${binPath}:$PATH

      rootDisk="/dev/vda${rootPartition}"

      # It is necessary to set root filesystem unique identifier in advance,
      # otherwise the bootloader might get the wrong one and fail to boot. At
      # the end, we reset again because we want deterministic timestamps.
      tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk
      # Make systemd-boot find ESP without udev.
      mkdir /dev/block
      ln -s /dev/vda1 /dev/block/254:1

      mountPoint=/mnt
      mkdir $mountPoint
      mount $rootDisk $mountPoint

      # Create the swapspace without turning it on.
      mkswap -U ${swapUUID} -L ${swapLabel} /dev/vda${swapPartition}
      swapon /dev/vda${swapPartition}

      # Install a configuration.nix
      mkdir -p /mnt/etc/nixos
      ${lib.optionalString (configFile != null) ''
        cp ${configFile} /mnt/etc/nixos/configuration.nix
      ''}

      ${lib.optionalString installBootLoader ''
        # In this throwaway resource, we only have `/dev/vda`, but the actual VM
        # may refer to another disk for bootloader, e.g. `/dev/vdb`. Use this
        # option to create a symlink from vda to any arbitrary device you want.
        ${lib.optionalString (
          config.boot.loader.grub.enable &&
          config.boot.loader.grub.device != "/dev/vda"
        ) ''
          mkdir -p $(dirname ${config.boot.loader.grub.device})
          ln -s /dev/vda ${config.boot.loader.grub.device}
        ''}

        # Set up core system link, bootloader (sd-boot, GRUB, uboot, etc.), etc.
        NIXOS_INSTALL_BOOTLOADER=1 nixos-enter --root $mountPoint -- \
          /nix/var/nix/profiles/system/bin/switch-to-configuration boot

        # The above scripts will generate a random machine-id and we don't want
        # to bake a single ID into all our images.
        rm -f $mountPoint/etc/machine-id
      ''}

      umount -R /mnt

      # Make sure resize2fs works. Note that resize2fs has stricter criteria for
      # resizing than a normal mount, so the `-c 0` and `-i 0` don't affect it.
      # Setting it to `now` doesn't produce deterministic output, of course, but
      # we can fix that when/if we start making images deterministic. This is
      # fixed to 1970-01-01 (UNIX timestamp 0). This two-step approach is
      # necessary otherwise `tune2fs` will want a fresher filesystem to perform
      # some changes.
      tune2fs -T now -U ${rootFSUID} -c 0 -i 0 $rootDisk
      tune2fs -f -T 19700101 $rootDisk
    ''
  );
in
  buildImage
