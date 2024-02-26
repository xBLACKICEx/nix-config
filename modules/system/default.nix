{ ... }: {
  imports = [
    ./desktop.nix
    ./fonts.nix
    ./i18n.nix
    ./network.nix
    ./peripherals.nix
    ./peripherals.nix
    ./pkgs.nix
  ];
  # others
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
