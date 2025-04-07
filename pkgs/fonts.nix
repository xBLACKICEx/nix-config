{
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "my_fonts";
  version = "1.0.0";

  src = ./my_fonts;

  installPhase = ''
    install -D -m 444 "$src"/* -t $out/share/fonts/
  '';

  meta = with lib; {
    description = "my fonts";
  };
}
