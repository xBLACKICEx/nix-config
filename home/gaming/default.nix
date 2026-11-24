{ config, outputs, ... }:
{
  imports = [
    outputs.homeManagerModules.gaming
  ];

  gaming = {
    enable = true;
    # Same library as beatrice: /games-lib is group-writable for both accounts,
    # and ~/.local/share/Steam/userdata stays per-user.
    steamLibrary = "/games-lib/steam/steamapps";
  };

  home.stateVersion = "26.11";

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  programs.bash.enable = true;

  home.file."Games".source = config.lib.file.mkOutOfStoreSymlink "/games-lib";
}
