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
        "/etc/passwd"
        "/etc/shadow"
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

  qt.style = "kvantum";


  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "michiha" ];

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.steam.enable = true;

  environment.systemPackages = with pkgs;[
    kdePackages.qtdeclarative
    kdePackages.wallpaper-engine-plugin
    kdePackages.neochat
    inputs.quickshell.packages.${pkgs.system}.default

    zed-editor
    jetbrains.clion
    jetbrains.goland
    jetbrains.rust-rover
  
  ];

  users.groups.shards = {
    gid = 4672;
  };

  # Users on system
  users.users = {
    michiha = {
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

    miwu = {
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

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
  users.groups.libvirtd.members = [ "michiha" "beatrice" "miwu" ];
  nix.settings.trusted-users = [ "michiha" "beatrice" "miwu" ];
}
