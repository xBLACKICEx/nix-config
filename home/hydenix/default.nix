{ inputs, lib, ... }:

{
  imports = [
    # inputs.hydenix.homeModules.default
  ];

  # hydenix.hm = {
  #   enable = true;
  #   hyde.enable = true;
  #   theme.enable = true;
  # };

  # programs.home-manager.enable = true;
  home.stateVersion = lib.mkForce "26.05";
}
