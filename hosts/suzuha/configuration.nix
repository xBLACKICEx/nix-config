{
  pkgs,
  inputs,
  outputs,
  lib,
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
    # inputs.hydenix.nixosModules.default
    inputs.dms.nixosModules.greeter
  ];

  networking.hostName = "suzuha";
  system.stateVersion = lib.mkForce "26.05";

  # Desktop
  desktop.hypr.enable = true;
  desktop.kde.enable = true;
  desktop.niri.enable = true;
  # desktop.cosmic.enable = true;
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    # compositor.customConfig = ''
    #   env = DMS_RUN_GREETER,1

    #   monitor = DP-1, 5120x2160@100.03, 0x0, 1.25, bitdepth, 12
    #   monitor = eDP-1, 1920x1080@60, 1088x1728, 1

    #   misc {
    #     disable_hyprland_logo = true
    #   }
    # '';
  };

  # Remote desktop / streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };

  # Core persistence
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

  # Security / keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Optional desktop/display alternatives
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

  # Programs
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.virt-manager.enable = true;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = false;
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bash}/bin/bash -c 'umask 0077 && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --with-key=host --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  ];
  # virtualisation.virtualbox.host.enable = true;
  users.groups.docker.members = [ "michiha" ];
  users.groups.libvirtd.members = [
    "michiha"
    "beatrice"
    "hydenix"
  ];
  users.extraGroups.vboxusers.members = [ "michiha" ];

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

  # Packages
  environment.systemPackages = with pkgs; [
    firefox
    google-chrome
    inputs.zen-browser.packages."${system}".default
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.rust-rover
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    # kdePackages.wallpaper-engine-plugin
    # kdePackages.neochat
    moonlight-qt
    simple-scan
    zed-editor

    stm32cubemx
  ];

  # Groups
  users.groups = {
    plugdev = { };
    shards = {
      gid = 4672;
    };
  };

  # Users
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
        "scanner"
        "lp"
      ];
    };

    beatrice = {
      hashedPassword = "$6$Q1OL1OyubefZMdhd$1IV3ZgdT07h7o1sU3DUXJZm4sFqGecdE9tPk7dtkkr25N1WNWVYRPfyEnIqDfuQnWNR5Uvi4LMmqsolnqDt/G0";
      isNormalUser = true;
      description = "beatrice";
      enable = true;
      extraGroups = commonUserGroups ++ [
        "scanner"
        "lp"
      ];
    };

    hydenix = {
      hashedPassword = "$6$Q1OL1OyubefZMdhd$1IV3ZgdT07h7o1sU3DUXJZm4sFqGecdE9tPk7dtkkr25N1WNWVYRPfyEnIqDfuQnWNR5Uvi4LMmqsolnqDt/G0";
      isNormalUser = true;
      description = "hydenix";
      enable = true;
      extraGroups = commonUserGroups;
    };
  };

  # Optional hydenix module config
  # hydenix = {
  #   enable = true;
  #
  #   hostname = "suzuha";
  #   timezone = "Europe/Paris";
  #   locale = "zh_CN.UTF-8";
  #
  #   audio.enable = false;
  #   boot.enable = false;
  #   network.enable = false;
  #
  #   hardware.enable = true;
  #   nix.enable = true;
  #   system.enable = true;
  #   sddm.enable = true;
  # };

  # Nix
  nix.settings.trusted-users = [
    "michiha"
    "beatrice"
    "hydenix"
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
