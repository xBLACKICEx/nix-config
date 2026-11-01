# GIGABYTE Mother Borde, Ryzen 9 9950X3D, Radeon RX 9070 XT.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
    "nvme"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.settings.extra-platforms = [ "aarch64-linux" ];
  # Required for the verified Corsair DDR5 RGB path on this board's AMD SMBus.
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  boot.supportedFilesystems = [
    "btrfs"
    "exfat"
    "ext4"
    "fat"
    "ntfs"
    "vfat"
    "xfs"
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
        enable = true;
        style = "hackerden";
        icon = "color";
        resolution = "1080p";
      };
    };
  };

  # Target disk for the 500GB NVMe SSD. NixOS uses 512MB ESP + 300GB root,
  # leaving the rest of the drive unallocated.
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "relatime"
        "mode=755"
      ];
    };

    disk.main = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            label = "ESP";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0022"
                "dmask=0022"
              ];
            };
          };

          root = {
            size = "1562G";
            type = "8304";
            label = "ROOT";
            content = {
              type = "luks";
              name = "REVA";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "NixOS"
                ];
                subvolumes = {
                  "/" = {
                    mountpoint = "/btr_pool";
                    mountOptions = [ "subvolid=5" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "48G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # MT7927 Wi-Fi uses the in-tree mt7925e driver. Its Bluetooth half uses
  # btusb/btmtk, but linux-firmware does not yet ship the MT6639 Bluetooth blob.
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.callPackage ./mt7927-bluetooth-firmware.nix { })
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
  };
  services.xserver.videoDrivers = [ "amdgpu" ];
  # Motherboard/ARGB headers, Corsair DDR5 and NZXT lighting.
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb.withPlugins [
      pkgs.openrgb-plugin-effects
      pkgs.openrgb-plugin-hardwaresync
    ];
  };
  programs.coolercontrol.enable = true;
}
