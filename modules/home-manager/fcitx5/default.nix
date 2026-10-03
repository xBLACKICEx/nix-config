{ config, inputs, lib, pkgs, mylib, ... }:
let
  rimeSource = "${inputs.dotfiles}/general/fcitx5/configs/input_methode";
  rimeUserDir = "${config.xdg.dataHome}/fcitx5/rime";
in
{
  home.file.".config/fcitx5/conf" = {
    # Fcitx rewrites these runtime files as regular files. Managing them as
    # store symlinks makes subsequent HM activations fail (including unrelated
    # service updates) once a same-named backup already exists.
    source = lib.cleanSourceWith {
      src = "${inputs.dotfiles}/general/fcitx5/configs/conf";
      filter = path: type: !(lib.elem (baseNameOf path) [
        "cached_layouts"
        "notifications.conf"
      ]);
    };
    recursive = true;
  };

  # Rime detects changes by mtime. Store symlinks retain epoch timestamps,
  # so an existing compiled configuration can hide newly installed patches.
  # Copy changed source files after Home Manager removes the old symlinks;
  # leave Rime's build output and learned dictionaries under its control.
  home.activation.installRimeConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] (mylib.nu.run ''
    let source_dir = "${rimeSource}"
    let user_dir = "${rimeUserDir}"
    mkdir $user_dir
    for name in [default.custom.yaml double_pinyin_mspy.schema.yaml] {
      let source_file = ($source_dir | path join $name)
      let target_file = ($user_dir | path join $name)
      let changed = if ($target_file | path type) == "file" {
        (open --raw $source_file) != (open --raw $target_file)
      } else {
        true
      }
      if $changed {
        ^${pkgs.coreutils}/bin/install -m 600 $source_file $target_file
      }
    }
  '');

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
    "fcitx5/config" = {
      source = "${inputs.dotfiles}/general/fcitx5/configs/config";
      force = true;
    };
    "fcitx5/profile" = {
      source = "${inputs.dotfiles}/general/fcitx5/configs/profile";
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
  };
}
