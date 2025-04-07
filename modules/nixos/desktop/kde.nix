{ config, lib, ... }:

with lib; {
  options.desktop.kde.enable = mkEnableOption "Enable KDE Plasma Desktop Environment";

  config = mkIf config.desktop.kde.enable {
    # desktop settings

    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.plasma6.enable = true;

    # SDDM
    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };

    security.pam.services.plasma6.enableKwallet = true;
    programs.kdeconnect.enable = true;
  };
}
