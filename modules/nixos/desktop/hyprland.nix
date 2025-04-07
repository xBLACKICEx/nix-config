{ config, inputs, lib, pkgs, ... }:

with lib; {
  options.desktop.hypr.enable = mkEnableOption "Enable hypr Plasma Desktop Environment";

  config = mkIf config.desktop.hypr.enable {
    programs.hyprland = {
      enable = true;

      # set the flake package
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };

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
