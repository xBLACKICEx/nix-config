{ pkgs, ... }:
{
  # system fonts
  fonts.packages = with pkgs; [
    my_fonts
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "AaOS可爱小海狸 (非商业使用)" ];
      serif = [ "AaOS可爱小海狸 (非商业使用)" ];
      monospace = [ "AaOS可爱小海狸 (非商业使用)" ];
    };
  };
}
