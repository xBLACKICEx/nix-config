{ ... }: {
  home.file.".local/share/fonts" = {
    source = ./my_fonts;
    recursive = true; # 递归整个文件夹
  };

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "AaOS可爱小海狸 (非商业使用)" ];
    serif = [ "AaOS可爱小海狸 (非商业使用)" ];
    monospace = [ "AaOS可爱小海狸 (非商业使用)" ];
  };
}
