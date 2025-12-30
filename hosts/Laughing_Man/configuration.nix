# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ outputs, pkgs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nixos/disko-config.nix
    outputs.nixosModules.core
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

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    allowSFTP = true;
  };


  # NixOS Modules Core Setups
  core.impermanence = {
    enable = true;
    users = {
      h4x0r_k4n3da = {
        directories = [
          "nix-config"

          "Desktop"
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "Templates"

          ".ssh"

          # vscode
          ".vscode"
          ".vscode-insiders"
          ".config/Code/User"
          ".config/Code - Insiders/User"

          # browsers
          ".mozilla"
          ".zen"

          ".local/share"
          ".local/state"

        ];

        files = [
          ".config/nushell/history.txt"
        ];
      };
    };
  };

  networking.hostName = "Laughing_Man";

  # Users on system
  users.users.h4x0r_k4n3da = {
    isNormalUser = true;
    description = "h4x0r_k4n3da";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
  };
  users.groups.libvirtd.members = [ "h4x0r_k4n3da" ];

  nix.settings.trusted-users = [ "h4x0r_k4n3da" ];
  system.stateVersion = "26.05"; # Did you read the comment?
}
