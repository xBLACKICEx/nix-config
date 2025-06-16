# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, outputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    outputs.nixosModules.core
    outputs.nixosModules.desktop
  ];
  networking.hostName = "suzuha";
  system.stateVersion = "25.05";

  # BEGIN -- CUSTOM NIXOS MODULES CONFIGURATION -- BEGIN #
  desktop.kde.enable = true;
  desktop.hypr.enable = true;

  # NixOS Modules Core Setups
  core.impermanence = {
    enable = true;
    persistence = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/home"
        "/etc/ssh"
        "/etc/nixos/nix-config"

        "/etc/agenix"

        "/root"
        "/var"
      ];
    };
  };
  # END -- CUSTOM NIXOS MODULES CONFIGURATION -- END #


  # services.xserver.desktopManager.deepin.enable = true;

  # services.deepin.deepin-anything.enable = true;

  # services.deepin.dde-daemon.enable = true;

  # services.deepin.dde-api.enable = true;

  # services.deepin.app-services.enable = true;

  # services.displayManager.sddm = {
  #   enable = true;
  #   autoNumlock = true;
  #   wayland.enable = true;
  #   enableHidpi = true;
  # };
  # services.xserver.enable = true;

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.steam.enable = true;

  qt.style = "kvantum";
  qt.platformTheme = "qt5ct";
  qt.enable = true;
  environment.systemPackages = with pkgs;[
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    kdePackages.wallpaper-engine-plugin
    kdePackages.neochat
    inputs.quickshell.packages.${pkgs.system}.default

    zed-editor
    jetbrains.clion
    jetbrains.goland
    jetbrains.rust-rover

    firefox
    google-chrome
  ];

  users.groups.shards = {
    gid = 4672;
  };

  # Users on system
  users.users = {
    root = {
      hashedPassword = "$6$BKXv3QWuBJAnRYNK$uP.PDS1qmkCDvr2IBLw9mLyNhUP0Js7hGfPYBnRTE3Jc8Om24/ae/O6hn7jH58eCYM9L7zIM7EXb9es.10iO00";
    };
    michiha = {
      hashedPassword = "$6$iBSb93jkx9FGya9x$q7riq6BxEZhXyNAoVCvPc62Br98Y2x69U4lgME8H4cJbXpebRVZsT7NZhhw2h1zumLuVZtJF.ZyXVicNQr1/7.";
      isNormalUser = true;
      description = "michiha";
      enable = true;
      extraGroups = [
        "shards"
        "wheel"
        "networkmanager"
        "libvirtd"
        "audio"
        "video"
        "plugdev"
        "input"
        "kvm"
        "qemu-libvirtd"
      ];
    };

    beatrice = {
      hashedPassword = "$6$Q1OL1OyubefZMdhd$1IV3ZgdT07h7o1sU3DUXJZm4sFqGecdE9tPk7dtkkr25N1WNWVYRPfyEnIqDfuQnWNR5Uvi4LMmqsolnqDt/G0";
      isNormalUser = true;
      description = "beatrice";
      enable = true;
      extraGroups = [
        "shards"
        "wheel"
        "networkmanager"
        "libvirtd"
        "audio"
        "video"
        "plugdev"
        "input"
        "kvm"
        "qemu-libvirtd"
      ];
    };

  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  users.extraGroups.vboxusers.members = [ "michiha" ];
  users.groups.docker.members = [ "michiha" ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
  users.groups.libvirtd.members = [ "michiha" "beatrice" ];
  nix.settings.trusted-users = [ "michiha" "beatrice" ];
}
