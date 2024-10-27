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
  programs.direnv.enable = true;
  # others
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nix.settings.trusted-users = [ "michiha" ];
}
