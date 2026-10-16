{ pkgs, ... }:
{
  # system fonts
  fonts.packages = with pkgs; [
    my_fonts
    maple-mono.NF-CN
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    lxgw-wenkai
  ];

  fonts.fontconfig = {
    enable = true;
    useEmbeddedBitmaps = true;
    defaultFonts = {
      sansSerif = [ "LXGW WenKai" ];
      serif = [ "LXGW WenKai" ];
      monospace = [ "LXGW WenKai Mono" ];
    };
  };
}
