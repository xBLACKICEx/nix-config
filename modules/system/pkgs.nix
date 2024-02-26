{ pkgs, inputs, ...}:
{
  # system leve apps
  environment.systemPackages = with pkgs; [
    neofetch

    vscode
    nushellFull
    zoxide
    bat
    starship
    fzf
    git
    nil
    nixpkgs-fmt

    # archives
    zip
    xz
    unzip
    p7zip

    # 这里从 helix 这个 inputs 数据源安装了 helix 程序
    inputs.helix.packages."${pkgs.system}".helix
  ];

  # others
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
