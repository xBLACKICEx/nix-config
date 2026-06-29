{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    warp-terminal = prev.warp-terminal.override { waylandSupport = true; };
    orca-slicer = (prev.orca-slicer.override {
      eigen = prev.eigen_5;
      wxwidgets_3_1 = prev.wxwidgets_3_3 // {
        override = _args: prev.wxwidgets_3_3;
      };
    }).overrideAttrs (oldAttrs: {
      version = "2.4.0-beta";

      src = prev.fetchFromGitHub {
        owner = "OrcaSlicer";
        repo = "OrcaSlicer";
        rev = "fc9a8aa93f7d341c3028d275781d77d2f385023e";
        hash = "sha256-bx4faVtEkcqBXzSXBXIsntDA4EFxDxWyUeI583tYhdw=";
      };

      patches =
        builtins.filter
          (patch: !(prev.lib.hasInfix "pr-7650-configurable-update-check.patch" (toString patch)))
          (oldAttrs.patches or [])
        ++ prev.lib.optional (builtins.pathExists ./patches/configurable-update-check-v2.4.0-beta.patch)
          ./patches/configurable-update-check-v2.4.0-beta.patch;

      meta = oldAttrs.meta // {
        changelog = "https://github.com/OrcaSlicer/OrcaSlicer/releases/tag/v2.4.0-beta";
      };
    });
    # app2unit = prev.app2unit.overrideAttrs (old: {
    #   # Upstream script changed; keep shebang rewrite strict but allow terminal-handler
    #   # replacement to be skipped when the pattern no longer exists.
    #   postFixup =
    #     builtins.replaceStrings
    #       [ "--replace-fail 'A2U__TERMINAL_HANDLER=xdg-terminal-exec'" ]
    #       [ "--replace-warn 'A2U__TERMINAL_HANDLER=xdg-terminal-exec'" ]
    #       (old.postFixup or "");
    # });

  #  zen-browser =
  #     inputs.zen-browser.packages.${final.stdenv.hostPlatform.system}.beta-unwrapped.overrideAttrs (old: let
  #       libName = old.libName or "zen-bin-${old.version}";
  #       fx-autoconfig = builtins.fetchurl {
  #         url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
  #         sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
  #       };
  #       configprefs = builtins.fetchurl {
  #         url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/refs/heads/master/program/defaults/pref/config-prefs.js";
  #         sha256 = "sha256-a/0u0TnRj/UXjg/GKjtAWFQN2+ujrckSwNae23DBfs4=";
  #       };
  #     in {
  #       postInstall = (old.postInstall or "") + ''
  #         chmod -R u+w "$out/lib/${libName}"
  #         cp "${fx-autoconfig}" "$out/lib/${libName}/config.js"
  #         mkdir -p "$out/lib/${libName}/defaults/pref"
  #         cp "${configprefs}" "$out/lib/${libName}/defaults/pref/config-prefs.js"
  #       '';
  #     });
  };

  stable-packages = final: _prev: {
    pkgsStable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
