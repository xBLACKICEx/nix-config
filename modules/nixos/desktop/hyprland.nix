{ config, inputs, lib, pkgs, ... }:

with lib; {
  imports = [inputs.hyprland.nixosModules.default];
  options.desktop.hypr.enable = mkEnableOption "Enable hypr Plasma Desktop Environment";

  config = mkIf config.desktop.hypr.enable {
    security.pam.services.hyprlock = {};
    
    programs.hyprland = {
      enable = true;
      withUWSM = true;

      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      plugins = with inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}; [
        hyprscrolling
      ];
    };

    environment.systemPackages = with pkgs; [
      hyprls
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
