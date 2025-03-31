{ pkgs, inputs, anyrun, ... }: {
  environment.systemPackages = with pkgs; [
    waybar
    inputs.quickshell.packages.${pkgs.system}.default
    kdePackages.qtdeclarative
    qml-ts-mode
    eww

    hyprlandPlugins.hyprbars
    hyprlandPlugins.hyprsplit
    hyprpicker # color picker
    hypridle # idle timeout
    hyprlock # locking the screen
    hyprshot # screen shot
    hyprls # a hyprland language server

    wlogout # logout menu

    wofi

    cliphist
    wl-clipboard

    wf-recorder
    slurp

    # notify
    # mako # the notification daemon, the same as 
    dunst
    libnotify

    rofi-wayland
    anyrun.packages.${pkgs.system}.anyrun
  ];
}
