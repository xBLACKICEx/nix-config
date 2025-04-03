# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./impermanence.nix
    ../../modules/system
  ];

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  systemd.services.nix-daemon = {
    environment = {
      # 指定临时文件的位置
      TMPDIR = "/var/cache/nix";
    };
    serviceConfig = {
      # 在 Nix Daemon 启动时自动创建 /var/cache/nix
      CacheDirectory = "nix";
    };
  };
  environment.variables.NIX_REMOTE = "daemon";
  
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    gtk3
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # Define hostname michiha@suzyha, poporo@suzyha ...
  networking.hostName = "suzuha";

  # Users on system
  users.users.michiha = {
    isNormalUser = true;
    description = "michiha";
    extraGroups = [ "networkmanager" "wheel" "input"];
    packages = with pkgs; [
      firefox
      kdePackages.kate
    ];
    hashedPassword = "$6$5RL6IW3tvRdIELcy$mSKtkhUEHBl6Xedq1bxImfUyX.jFift82bRIyj2MVHO.OS1tMSYf6aTk3DkIhnTJ0oEczLUqJZaAiz4h3pg7j/";
  };
  users.groups.libvirtd.members = [ "michiha" ];

  nix.settings.trusted-users = [ "michiha" ];
  system.stateVersion = "25.05"; # Did you read the comment?
}
