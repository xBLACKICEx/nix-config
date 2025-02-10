{ pkgs, inputs, ... }:
let
  waveterm = pkgs.callPackage  ../../waveterm.nix  { };
in
{
  # system leve apps
  environment.systemPackages = with pkgs; [
    neofetch

    vscode
    nushell
    zoxide
    bat
    starship
    fzf
    git
    nil
    nixd
    motrix

    # nix tools
    nixpkgs-fmt
    nix-output-monitor

    # archives
    zip
    xz
    unzip
    p7zip

    waveterm

  ];

  # others
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
 
