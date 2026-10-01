# Hardware and disk layout for suzuha. Keep this file when reinstalling.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Reinstall layout for the existing NixOS partition only.
  # The shared ESP and Windows partitions are outside disko.
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "relatime" "mode=755" ];
    };

    disk.nixosPartition = {
      type = "disk";
      device = "/dev/disk/by-partlabel/nixos";
      destroy = false;
      content = {
        type = "luks";
        name = "crypted-nixos";
        settings.bypassWorkqueues = true;
        content = {
          type = "btrfs";
          extraArgs = [ "-f" "-L" "crypted-nixos" ];
          mountpoint = "/btr_pool";
          mountOptions = [ "subvolid=5" ];
          subvolumes = {
            "@nix" = {
              mountpoint = "/nix";
              mountOptions = [ "noatime" "compress-force=zstd:1" ];
            };
            "@persistent" = {
              mountpoint = "/persistent";
              mountOptions = [ "compress-force=zstd:1" ];
            };
            "@tmp" = {
              mountpoint = "/tmp";
              mountOptions = [ "compress-force=zstd:1" ];
            };
            "@snapshots" = {
              mountpoint = "/snapshots";
              mountOptions = [ "compress-force=zstd:1" ];
            };
            "@swap" = {
              mountpoint = "/swap";
              swap.swapfile.size = "16G";
            };
          };
        };
      };
    };
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];

  # networking bug fix for rtw89_8852be
  # https://github.com/lwfinger/rtw89/issues/308
  boot.extraModprobeConfig = ''
    options rtw89_pci disable_aspm_l1=Y
    options rtw89_pci disable_aspm_l1ss=Y
    options rtw89pci disable_aspm_l1=Y
    options rtw89pci disable_aspm_l1ss=Y
  '';
  # https://github.com/lwfinger/rtw89/issues/308
  environment.etc."systemd/system-sleep/suspend_rtw89".source =
    pkgs.writeShellScript "suspend_rtw89" ''
      if [ "$1" == "pre" ]; then
        /run/current-system/sw/bin/modprobe -rv rtw89_8852be
      elif [ "$1" == "post" ]; then
        /run/current-system/sw/bin/modprobe -v rtw89_8852be
      fi
    '';

  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "xfs"
    "ntfs"
    "fat"
    "vfat"
    "exfat"
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      useOSProber = true;
      dedsec-theme = {
        # grub theme module dedsec-theme
        enable = true;
        style = "hackerden";
        icon = "color";
        resolution = "1080p";
      };
    };
  };

  fileSystems."/persistent".neededForBoot = true;

  # remount swapfile in read-write mode
  fileSystems."/swap/swapfile" = {
    # the swapfile is located in /swap subvolume, so we need to mount /swap first.
    depends = [ "/swap" ];

    device = "/swap/swapfile";
    fsType = "none";
    options = [
      "bind"
      "rw"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1BA3-945B";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/4ED462C7D462B0BF";
    fsType = "ntfs3";
    options = [
      "uid=1002"
      "gid=4672"
      "umask=002"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=3s"
    ];
  };

  # fileSystems."/mnt/dev" = {
  #   device = "/dev/disk/by-uuid/CAD6477BD64766B3";
  #   fsType = "ntfs3";
  #   options = [
  #     "uid=1002"
  #     "gid=4672"
  #     "umask=002"
  #     "nofail"
  #     "x-systemd.automount"
  #     "x-systemd.device-timeout=3s"
  #   ];
  # };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f4u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
