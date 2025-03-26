{pkgs}: let
  callPackage = pkgs.lib.callPackageWith pkgs;
in {
  qml-ts-mode = callPackage ./qml-ts-mode.nix {};
}