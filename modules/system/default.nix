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

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
