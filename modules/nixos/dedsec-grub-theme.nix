{ config
, lib
, pkgs
, inputs
, ...
}:
let
  cfg = config.boot.loader.grub.dedsec-theme;

  dedsecGrubTheme = pkgs.stdenv.mkDerivation {
    pname = "dedsec-grub-theme";
    version = "unstable-2022-09-03";
    src = inputs.dedsec-grub-theme;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/grub/theme"
      cp "assets/backgrounds/${cfg.style}-${cfg.resolution}.png" "$out/grub/theme/background.png"
      cp -r "assets/icons-${cfg.resolution}/${cfg.icon}" "$out/grub/theme/icons"
      cp -r "assets/fonts/${cfg.resolution}/." "$out/grub/theme/"
      cp -r "base/${cfg.resolution}/." "$out/grub/theme/"
      runHook postInstall
    '';
  };
in
{
  options.boot.loader.grub.dedsec-theme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable DedSec grub theme.";
    };

    style = lib.mkOption {
      type = lib.types.enum [
        "brainwash"
        "compact"
        "comments"
        "firewall"
        "fuckery"
        "hackerden"
        "legion"
        "lovetrap"
        "mashup"
        "reaper"
        "redskull"
        "stalker"
        "spam"
        "spyware"
        "strike"
        "sitedown"
        "trolls"
        "tremor"
        "unite"
        "wannacry"
        "wrench"
      ];
      example = "hackerden";
      description = "Theme variant for grub.";
    };

    icon = lib.mkOption {
      type = lib.types.enum [ "color" "white" ];
      default = "color";
      example = "color";
      description = "Icon color variant.";
    };

    resolution = lib.mkOption {
      type = lib.types.enum [ "1080p" "1440p" ];
      default = "1080p";
      example = "1080p";
      description = "Theme resolution.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ dedsecGrubTheme ];
    boot.loader.grub.theme = "${dedsecGrubTheme}/grub/theme";
  };
}
