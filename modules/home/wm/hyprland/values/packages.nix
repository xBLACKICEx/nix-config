{
  pkgs,
  # pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    swww
    waybar # the status bar
    swaybg # the wallpaper
    swayidle # the idle timeout
    swaylock # locking the screen
    wlogout # logout menu
    wl-clipboard # copying and pasting
    hyprpicker # color picker
    hypridle # idle timeout
    hyprlock # locking the screen

    hyprshot # screen shot
    grim # taking screenshots
    slurp # selecting a region to screenshot
    wf-recorder # creen recording

    mako # the notification daemon, the same as dunst
    libnotify # for mako 
    bemenu # a bemenu backend for wlroots
    swappy # a simple wayland screenshot tool
    cliphist # clipboard history
  

    yad # a fork of zenity, for creating dialogs

    # audio
    alsa-utils # provides amixer/alsamixer/...
    mpd # for playing system sounds
    mpc-cli # command-line mpd client
    ncmpcpp # a mpd client with a UI
    networkmanagerapplet # provide GUI app: nm-connection-editor
  ];
}
