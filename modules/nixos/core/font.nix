{ pkgs, ... }:
{
  # system fonts
  fonts.packages = with pkgs; [
    my_fonts
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    lxgw-wenkai
  ];

  fonts.fontconfig = {
    enable = true;
    useEmbeddedBitmaps = true;
    defaultFonts = {
      sansSerif = [ "lxgw-wenkai" ];
      serif = [ "lxgw-wenkai" ];
      monospace = [ "lxgw-wenkai" ];
    };
  };
}
