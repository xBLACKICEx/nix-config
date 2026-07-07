{ pkgs, inputs, outputs, ... }: {
  programs.home-manager.enable = true;
  home.stateVersion = "26.11";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
