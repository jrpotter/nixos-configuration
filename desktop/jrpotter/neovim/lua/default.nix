{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "lua";
  src = ./.;
  installPhase = ''
    mkdir -p $out/
    cp -r ./* $out/
  '';
}
