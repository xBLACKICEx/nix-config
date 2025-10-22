{  inputs, ... }:
{
  home.file.".config/fcitx5/conf" = {
    source = "${inputs.dotfiles}/general/fcitx5/configs";
    recursive = true;
  };

  home.file.".local/share/fcitx5/themes/ayaya-dark" = {
    source = "${inputs.fcitx5-theme-ayaya}/ayaya-dark";
    recursive = true;
  };

  home.file.".local/share/fcitx5/themes/ayaya-light" = {
    source = "${inputs.fcitx5-theme-ayaya}/ayaya-light";
    recursive = true;
  };

  home.file.".local/share/fcitx5/themes/" = {
    source = "${inputs.fcitx5-themes-candlelight}";
    recursive = true;
  };

    xdg.configFile = {
    "fcitx5/profile" = {
      source = "${inputs.dotfiles}/general/fcitx5/configs/profile";
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
  };
}
