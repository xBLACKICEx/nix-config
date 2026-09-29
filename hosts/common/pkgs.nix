{
  pkgs,
  inputs,
  outputs,
  ...
}:
{

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

      # DeepSeek Harness 的 `dsh` scope，供 home/michiha 里的
      # programs.dsh 使用。home-manager 开了
      # useGlobalPkgs = true，overlay 必须加在 NixOS 这一层；写在用户模块的
      # nixpkgs.overlays 里不会影响 Home Manager 看到的 pkgs，会报
      # `attribute 'dsh' missing`。
      inputs.deepseek-harness.overlays.default

      # inputs.hydenix.overlays.default

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # problems.handlers.spacedrive.broken = "warn";
    };
  };

  environment.systemPackages = with pkgs; [
    # Archives and Compression Tools
    zip # Standard zip compression utility
    xz # XZ compression utility
    zstd # Zstandard real-time compression algorithm
    unzipNLS # Unzip with native language support
    p7zip # 7-zip compression program

    mission-center
    copyq

    # Shell and Terminal Utilities
    nushell # Modern shell written in Rust
    nufmt # Format Nushell scripts
    starship # Cross-shell prompt

    # Network and Download Tools
    wget # Command-line utility for downloading files
    curl # Command-line tool for transferring data
    aria2 # Lightweight multi-protocol download utility

    # File and Text Processing
    lsd # modern replacement for ls
    fd # Simple, fast and user-friendly alternative to find
    ripgrep # Fast text search tool
    jq # Command-line JSON processor
    bat # Cat clone with syntax highlighting
    fzf # Command-line fuzzy finder
    zoxide # Smarter cd command

    # System Information
    fastfetch # System information tool with ASCII art logo

    expect # Automate interactive applications
    # spacedrive
    codex
    # codex-acp
    # rio
    # kitty

    (pkgs.freecad.override {
      python3Packages = pkgs.python3Packages.overrideScope (
        pyFinal: pyPrev: {
          ifcopenshell = pyPrev.ifcopenshell.override {
            boost = pkgs.boost190;
          };
        }
      );
    })
    # orca-slicer
    kicad
  ];

  services.udev.packages = with pkgs; [
    platformio-core
    openocd
    stlink
    probe-rs-tools
  ];

  # https://github.com/NixOS/nixpkgs/issues/149812
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';
}
