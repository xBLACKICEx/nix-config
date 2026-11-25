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
    "shared"
    "video"
    "wheel"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    outputs.nixosModules.core
    outputs.nixosModules.desktop
    inputs.dank-greeter.nixosModules.default
  ];

  networking.hostName = "NERV_Recreation";
  system.stateVersion = lib.mkForce "26.11";

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # Desktop
  desktop.kde.enable = true;

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

  # Security / keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Programs
  programs.dconf.enable = true;
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
    firefox
    chromium
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    simple-scan
    zed-editor

      glow # 终端中的 Markdown 预览器

      btop # htop/nmon 的替代品
      iotop # IO 监控
      iftop # 网络监控

      # 系统调用监控
      strace # 系统调用监控
      ltrace # 库调用监控
      lsof # 列出打开的文件

      # 系统工具
      sysstat
      lm_sensors # 用于 `sensors` 命令
      ethtool
      pciutils # lspci
      usbutils # lsusb
      brightnessctl # 控制屏幕亮度，用于 Hyprland
      helix
  ];

  users.groups = {
    docker.members = [ "nerv" ];
    libvirtd.members = [ "nerv" ];
    plugdev = { };
    shared = { };
    syncthing-shared = { };
    configs = { };
  };

  users.users = {
    root = {
      hashedPasswordFile = "/persistent/configs/nix-config-private/passwords/root";
    };
    nerv = {
      linger = true;
      hashedPasswordFile = "/persistent/configs/nix-config-private/passwords/desktop";
      isNormalUser = true;
      description = "NERV";
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

  nix.settings.trusted-users = [ "nerv" ];
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
