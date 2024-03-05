{ ... }:
{
  home.file.".config/fcitx5/conf" = {
    source = ./configs;
    recursive = true;
  };
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./configs/profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
    "fcitx5/conf/classicui.conf" = {
      source = ./configs/conf/classicui.conf;
      force = true;
    };
  };
}
