{ config, lib, ... }:

with lib; {
  options.desktop.cosmic.enable = mkEnableOption "Enable COSMIC Plasma Desktop Environment";

  config = mkIf config.desktop.cosmic.enable {
    # desktop settings

    # Enable the KDE Plasma Desktop Environment.
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # # SDDM
    # services.displayManager.sddm = {
    #   enable = true;
    #   autoNumlock = true;
    #   wayland.enable = true;
    #   enableHidpi = true;
    # };

    security.pam.services.plasma6.enableKwallet = true;
    programs.kdeconnect.enable = true;
  };
}
