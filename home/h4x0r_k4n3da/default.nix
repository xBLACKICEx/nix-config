{ pkgs, inputs, outputs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
