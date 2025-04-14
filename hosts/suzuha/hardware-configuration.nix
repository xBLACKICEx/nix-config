# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.extraModulePackages = [ ];

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

  boot.initrd = {
    luks.devices."crypted-nixos" = {
      device = "/dev/disk/by-uuid/f865468b-13bd-4363-a1ab-44b764fc0f05";
      # Whether to bypass dm-crypt’s internal read and write workqueues.
      # Enabling this should improve performance on SSDs;
      # https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
      bypassWorkqueues = true;
    };
  };

  fileSystems."/" =
    {
      device = "tmpfs";
      fsType = "tmpfs";
      # 必须设置 mode=755，否则默认的权限将是 777，导致 OpenSSH 报错并拒绝用户登录
      options = [ "relatime" "mode=755" ];
    };

  fileSystems."/btr_pool" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvolid=5" ];
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress-force=zstd:1" ];
    };

  fileSystems."/gnu" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@guix" "noatime" "compress-force=zstd:1" ];
    };

  fileSystems."/tmp" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@tmp" "compress-force=zstd:1" ];
    };

  fileSystems."/swap" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@swap" "ro" ];
    };

  # remount swapfile in read-write mode
  fileSystems."/swap/swapfile" = {
    # the swapfile is located in /swap subvolume, so we need to mount /swap first.
    depends = [ "/swap" ];

    device = "/swap/swapfile";
    fsType = "none";
    options = [ "bind" "rw" ];
  };

  fileSystems."/persistent" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@persistent" "compress-force=zstd:1" ];
      # impermanence's data is required for booting.
      neededForBoot = true;
    };

  fileSystems."/snapshots" =
    {
      device = "/dev/disk/by-uuid/25577768-cc01-4436-842f-0da51f2a2925";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" "compress-force=zstd:1" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/1BA3-945B";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [{ device = "/swap/swapfile"; }];

  fileSystems."/mnt/windows" =
    {
      device = "/dev/disk/by-uuid/4ED462C7D462B0BF";
      fsType = "ntfs-3g";
    };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0f4u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
