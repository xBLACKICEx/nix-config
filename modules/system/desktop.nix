{ ... }: {
  # desktop settings
  services.xserver.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  security.pam.services.plasma5.enableKwallet = true;
  programs.kdeconnect.enable = true;
}
