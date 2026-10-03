{ lib, pkgs, python313, uv2nix, pyproject-nix, pyproject-build-systems }:
let
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = ./headroom;
  };
  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {
    python = python313;
  }).overrideScope (lib.composeManyExtensions [
    pyproject-build-systems.overlays.wheel
    (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
  ]);
  inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
in
(mkApplication {
  venv = pythonSet.mkVirtualEnv "headroom-env" { headroom-ai = [ "proxy" "code" ]; };
  package = pythonSet.headroom-ai;
}).overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Headroom context compression proxy with Nix-managed dependencies";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    platforms = lib.platforms.linux;
  };
})
