# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

    nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # desktop settings
  services.xserver.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  # input methode
  i18n.inputMethod = {
    enabled = "fcitx5";

    fcitx5.addons = with pkgs; [ fcitx5-rime fcitx5-chinese-addons fcitx5-table-extra ];
  };

  # location
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Users on system
  users.users.poporo = {
    isNormalUser = true;
    description = "poporo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
  };

  # system leve apps
  environment.systemPackages = with pkgs; [
    vscode
    nushellFull
    zoxide
    bat
    starship
    fzf
    git
    nil
    nixpkgs-fmt

    # 这里从 helix 这个 inputs 数据源安装了 helix 程序
    inputs.helix.packages."${pkgs.system}".helix
  ];

  # others
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
