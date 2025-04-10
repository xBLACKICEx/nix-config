{ config, pkgs, inputs, lib, ... }: {

  options.desktop.hypr.enable = lib.mkEnableOption "Enable Hyprland window manager";

  imports = [
    ../wayland.nix
  ];

  config =
    let hyprConfig = "${config.home.homeDirectory}/modules/home-manager/desktop/dotfiles/hyprland/hyprland.conf";
    in
    lib.mkIf config.desktop.hypr.enable {

      desktop.wayland.enable = true;
      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;

        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

        extraConfig = ''
          $configs = $HOME/.config/hypr/configs

          source= $configs/settings.conf
          source= $configs/keybinds.conf
          source= $configs/startup.conf
          source= $configs/variables.conf
          # source= $configs/window_rules.conf
          source= $configs/animations.conf
        '';

        plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
          hyprbars
        ];

      };

      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";

        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        #SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";

        NIXOS_OZONE_WL = "1"; # force wayland on electron apps
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      services.playerctld.enable = true;

      home.packages = with pkgs; [
        hyprlock
        hyprls

        pywal
        cava
        swww
        swaybg
        kitty
        waybar
        rofi-wayland
        swaynotificationcenter
        gnome-system-monitor
      ];

      nix.settings = {
        extra-substituters = [
          "https://hyprland.cachix.org"
        ];
        extra-trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    };
}
