{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  commonUserGroups = [
    "audio"
    "dialout"
    "input"
    "kvm"
    "libvirtd"
    "networkmanager"
    "plugdev"
    "qemu-libvirtd"
    "shards"
    "video"
    "wheel"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    outputs.nixosModules.core
    outputs.nixosModules.desktop
    inputs.dms.nixosModules.greeter
  ];

  networking.hostName = "NERV_Recreation";
  system.stateVersion = lib.mkForce "26.05";

  # Desktop
  desktop.kde.enable = true;
  desktop.hypr.enable = false;
  desktop.niri.enable = false;
  services.displayManager.dms-greeter.enable = false;

  # Remote desktop / streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

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

  # Core persistence
  core.impermanence = {
    enable = true;
    persistence = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
        "/etc/nixos/nix-config"
        "/etc/agenix"
        "/root"
        "/var"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  # Security / keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Programs
  programs.dconf.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.virt-manager.enable = true;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Networking / discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.syncthing.enable = true;

  # Printing / scanning
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ cnijfilter2 ];
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    google-chrome
    inputs.zen-browser.packages."${system}".default
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    moonlight-qt
    simple-scan
    zed-editor
  ];

  users.groups = {
    docker.members = [ "michiha" ];
    libvirtd.members = [ "michiha" ];
    plugdev = { };
    shards = {
      gid = 4672;
    };
  };

  users.users = {
    root = {
      hashedPassword = "$6$BKXv3QWuBJAnRYNK$uP.PDS1qmkCDvr2IBLw9mLyNhUP0Js7hGfPYBnRTE3Jc8Om24/ae/O6hn7jH58eCYM9L7zIM7EXb9es.10iO00";
    };
    michiha = {
      hashedPassword = "$6$iBSb93jkx9FGya9x$q7riq6BxEZhXyNAoVCvPc62Br98Y2x69U4lgME8H4cJbXpebRVZsT7NZhhw2h1zumLuVZtJF.ZyXVicNQr1/7.";
      isNormalUser = true;
      description = "michiha";
      enable = true;
      extraGroups = commonUserGroups ++ [
        "docker"
        "scanner"
        "lp"
      ];
    };
  };

  nix.settings.trusted-users = [ "michiha" ];
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
