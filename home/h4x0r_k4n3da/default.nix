{ pkgs, inputs, outputs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "26.05";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
