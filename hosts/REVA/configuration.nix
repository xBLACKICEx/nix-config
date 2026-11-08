{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  private = import (inputs.nix-config-private + "/flake-input/reva.nix");
  commonUserGroups = [
    "audio"
    "dialout"
    "input"
    "kvm"
    "libvirtd"
    "networkmanager"
    "plugdev"
    "qemu-libvirtd"
    "shared"
    "video"
    "wheel"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    ./network.nix
    outputs.nixosModules.core
    outputs.nixosModules.desktop
    inputs.dank-greeter.nixosModules.default
    inputs.syauth.nixosModules.default
  ];

  # Apply the wireless regulatory domain at boot.
  boot.kernelParams = [ "cfg80211.ieee80211_regdom=${private.wirelessCountry}" ];

  # This desktop should always prefer performance over power savings.
  services.power-profiles-daemon.enable = false;
  powerManagement.cpuFreqGovernor = "performance";

  # Telescope: match the device numbers expected by the desktop application.
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 video_nr=10,11 exclusive_caps=1 card_label="OBS Virtual Camera,Phone Camera"
  '';

  system.stateVersion = lib.mkForce "26.11";

  # Desktop
  desktop.kde.enable = true;
  desktop.hypr.enable = false;
  desktop.niri.enable = false;
  programs.dms-greeter.enable = false;

  # Keep the small SSD from filling up with stale generations and store paths.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = lib.mkForce "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Security / keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Programs
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.virt-manager.enable = true;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.services = {
    libvirtd.serviceConfig = {
      LoadCredentialEncrypted = lib.mkForce [ ];
      LoadCredential = [
        "secrets-encryption-key:/var/lib/libvirt/secrets/secrets-encryption-key"
      ];
    };
    virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
      ""
      "${pkgs.bash}/bin/bash -c 'umask 0077 && ${pkgs.coreutils}/bin/mkdir -p /var/lib/libvirt/secrets && ${pkgs.coreutils}/bin/dd if=/dev/random of=/var/lib/libvirt/secrets/secrets-encryption-key status=none bs=32 count=1'"
    ];
  };
  # Printing / scanning
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ cnijfilter2 ];
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  environment.systemPackages = with pkgs; [
    iw
    liquidctl
    firefox
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    moonlight-qt
    simple-scan
    zed-editor
  ];

  users.groups = {
    docker.members = [ "beatrice" ];
    libvirtd.members = [ "beatrice" ];
    plugdev = { };
    shared = { };
    syncthing-shared = { };
    configs = { };
  };

  users.users = {
    root = {
      hashedPasswordFile = "/persistent/configs/nix-config-private/passwords/root";
    };
    beatrice = {
      linger = true;
      hashedPasswordFile = "/persistent/configs/nix-config-private/passwords/desktop";
      isNormalUser = true;
      description = "ベアトリス";
      enable = true;
      extraGroups = commonUserGroups ++ [
        "docker"
        "scanner"
        "lp"
        "configs"
        "syncthing-shared"
      ];
    };
  };

  services.syauth = {
    enable = true;
    desktopUser = "beatrice";
    pam.services = [ "sudo" "sudo-i" "kde" "plasmalogin" ];
    pam.moduleArgs = [ "socket=/run/user/1000/syauth/auth.sock" ];
  };

  nix.settings.trusted-users = [ "beatrice" ];
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
