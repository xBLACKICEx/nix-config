{ pkgs, inputs, ... }:
{
  qt.style = "kvantum";
  # system leve apps
  environment.systemPackages = with pkgs; [
    # archiving
    p7zip
    unzip
    xz
    zip

    # cli tools
    awscli2
    bat
    fzf
    git
    neofetch
    nil
    nushell

    # formatting for nushell
    topiary
    tree-sitter
    tree-sitter-grammars.tree-sitter-nu

    starship
    zoxide

    vscode-fhs
    (zed-editor.overrideAttrs (oldAttrs: {
        postPatch = ''
          substituteInPlace $cargoDepsCopy/webrtc-sys-*/build.rs \
            --replace-fail "cargo:rustc-link-lib=static=webrtc" "cargo:rustc-link-lib=dylib=webrtc"

          substituteInPlace script/generate-licenses \
            --replace-fail 'CARGO_ABOUT_VERSION="0.6"' 'CARGO_ABOUT_VERSION="0.7"'
        '';
    }))

    # nix tooling
    nix-output-monitor
    nixd
    nixpkgs-fmt

    # multimedia
    kikoplay
    obs-studio

    # system
    expect
    xdg-user-dirs


    # Virtualization
    quickemu

    # Downloaders
    motrix
  ];

  # others
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

}
 
