{ pkgs, ... }: {

  imports = [
    ./kde.nix
    ./hyprland.nix
  ];

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  # environment.systemPackages = with pkgs; [
  #   grim
  #   xdg-user-dirs
  #   qt6.qtwayland
  #   waypipe
  #   wf-recorder
  #   wl-mirror
  #   wl-clipboard
  #   wlogout
  #   wtype
  #   ydotool
  # ];
}
