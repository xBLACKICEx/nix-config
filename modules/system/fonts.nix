{ pkgs, ... }:
let
  # my_fonts = pkgs.callPackage (../../my_fonts.nix) { };
in
{
  # system fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
  ];
}
