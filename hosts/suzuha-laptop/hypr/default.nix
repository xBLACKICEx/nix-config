{ ... }: {
  imports = [
    ./pkgs.nix
  ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM  = true;
  # environment.sessionVariables = {
  #   MOZ_ENABLE_WAYLAND = "1";
  #   NIXOS_OZONE_WL = "1";
  # };
  nix.settings = {
    builders-use-substitutes = true;
    extra-substituters = [
      "https://anyrun.cachix.org"
    ];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };
}
