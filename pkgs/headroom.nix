{
  lib,
  writeShellApplication,
  uv,
  stdenv,
  zlib,
}:
let
  headroomVersion = "0.37.0";
in
writeShellApplication {
  name = "headroom";
  runtimeInputs = [ uv ];
  text = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib ]}:''${LD_LIBRARY_PATH:-}"
    exec uvx --python 3.13 --from 'headroom-ai[proxy,code]==${headroomVersion}' headroom "$@"
  '';
  meta = {
    description = "Headroom context compression CLI, installed through Nix";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    platforms = lib.platforms.linux;
  };
}
