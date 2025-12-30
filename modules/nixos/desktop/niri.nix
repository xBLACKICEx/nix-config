{ inputs, config, lib, pkgs,... }:

with lib; {
  options.desktop.niri.enable = mkEnableOption "Enable Niri Desktop Environment";

  config = mkIf config.desktop.niri.enable {
    programs.niri = {
      enable = true;
      package = inputs.unofficial-niri.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };

    security.polkit.enable = true; # polkit
    services.gnome.gnome-keyring.enable = true; # secret service
    security.pam.services.swaylock = {};

    environment.sessionVariables = {
        # XDG_CURRENT_DESKTOP = "Niri";
        XDG_SESSION_TYPE = "wayland";
        # XDG_SESSION_DESKTOP = "Niri";

        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        SDL_VIDEODRIVER = "wayland,x11";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";

        NIXOS_OZONE_WL = "1"; # force wayland on electron apps
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
    environment.systemPackages = with pkgs; [ 
        xwayland-satellite # xwayland support
    ];
  };
}
