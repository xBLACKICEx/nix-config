{ lib, stdenv, requireFile }:

stdenv.mkDerivation rec {
  pname = "my_fonts";
  version = "0.0.2";

  src = builtins.fetchGit {
    url = "git@github.com:xBLACKICEx/my-fonts.git"; # private repo  buid with cmd ：nixos-rebuild switch --use-remote-sudo  --flake ".#your_device"
    # url = "https://github.com/xBLACKICEx/my-fonts.git"; # poblic repo
    ref = "refs/tags/0.0.2";
    rev = "422a4559b4859ee0e642df95475cf402c028c2f2";
  };


  installPhase = ''
    install -D -m 444 "OperatorMonoSSmLig"/* -t $out/share/fonts/
    install -D -m 444 "OPenDyslexicMono NF + Tensentype CongCongJ"/* -t $out/share/fonts/
  '';

  meta = with lib; {
    description = "my fonts";
  };
}
