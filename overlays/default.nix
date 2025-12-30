{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    warp-terminal = prev.warp-terminal.override { waylandSupport = true; };

   zen-browser =
      inputs.zen-browser.packages.${final.system}.beta-unwrapped.overrideAttrs (old: let
        libName = old.libName or "zen-bin-${old.version}";
        fx-autoconfig = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
          sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
        };
        configprefs = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/refs/heads/master/program/defaults/pref/config-prefs.js";
          sha256 = "sha256-a/0u0TnRj/UXjg/GKjtAWFQN2+ujrckSwNae23DBfs4=";
        };
      in {
        postInstall = (old.postInstall or "") + ''
          chmod -R u+w "$out/lib/${libName}"
          cp "${fx-autoconfig}" "$out/lib/${libName}/config.js"
          mkdir -p "$out/lib/${libName}/defaults/pref"
          cp "${configprefs}" "$out/lib/${libName}/defaults/pref/config-prefs.js"
        '';
      });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
