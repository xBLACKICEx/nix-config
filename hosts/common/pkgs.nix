{ pkgs, inputs, outputs, ... }: {

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.stable-packages

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
    lsd #  modern replacement for ls
    fd # Simple, fast and user-friendly alternative to find
    ripgrep # Fast text search tool
    jq # Command-line JSON processor
    bat # Cat clone with syntax highlighting
    fzf # Command-line fuzzy finder
    zoxide # Smarter cd command

    # System Information
    neofetch # System information tool with ASCII art logo

    expect # Automate interactive applications
    spacedrive
  ];

  # https://github.com/NixOS/nixpkgs/issues/149812
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';
}
