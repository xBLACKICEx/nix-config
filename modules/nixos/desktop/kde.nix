{ config, lib, inputs, pkgs, ... }:

with lib; {
  options.desktop.kde.enable = mkEnableOption "Enable KDE Plasma Desktop Environment";

  config = mkIf config.desktop.kde.enable {
    # desktop settings

    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;

    # SDDM
    services.displayManager.sddm = {
      enable = false;
      autoNumlock = true;
      wayland.enable = true;
      enableHidpi = true;
    };

    security.pam.services.plasma6.enableKwallet = false;
    programs.kdeconnect.enable = true;

    environment.systemPackages = [
      inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.default # Wayland
      inputs.kwin-effects-forceblur.packages.${pkgs.stdenv.hostPlatform.system}.x11 # X11
    ];
  };
}
