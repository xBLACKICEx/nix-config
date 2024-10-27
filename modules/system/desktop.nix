{ ... }: {
  # desktop settings

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  security.pam.services.plasma6.enableKwallet = true;

  programs.kdeconnect.enable = true;
}
