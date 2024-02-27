{ pkgs, ... }:
let
  my_fonts = pkgs.callPackage (../../my_fonts.nix) { };
in
{
  # system fonts
  fonts = {

    packages = with pkgs; [
      noto-fonts-emoji # 彩色的表情符号字体

      source-han-sans # 思源黑体
      source-han-serif # 思源宋体
      (nerdfonts.override {
        fonts = [
          # symbols icon only
          "NerdFontsSymbolsOnly"
          # Characters
          "FiraCode"
          "CascadiaCode"
        ];
      })
      my_fonts # 自定义字体
    ];
  };
}
