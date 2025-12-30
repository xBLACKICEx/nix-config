{ pkgs, ... }: {

  imports = [
    ./kde.nix
    ./cosmic.nix
    ./hyprland.nix
    ./niri.nix
  ];

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  environment.systemPackages = with pkgs; [
  #   grim
  #   xdg-user-dirs
  kdePackages.qtwayland
  #   waypipe
  #   wf-recorder
  #   wl-mirror
  #   wl-clipboard
  #   wlogout
  #   wtype
  #   ydotool
  ];
}
