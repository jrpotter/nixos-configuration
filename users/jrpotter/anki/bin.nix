{ pkgs, lib, commandLineArgs ? [] }:
let
  pname = "anki-bin";
  version = "23.12.1";

  linux = pkgs.fetchurl {
    url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-qt6.tar.zst";
    sha256 = "sha256-bFtAUqSoFS8CWESiepWXywndkijATbWp6CJdqlQecuk=";
  };

  unpacked = pkgs.stdenv.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [ pkgs.zstd ];
    src = linux;

    installPhase = ''
      runHook preInstall
      xdg-mime () {
        echo Stubbed!
      }
      export -f xdg-mime
      PREFIX=$out bash install.sh
      runHook postInstall
    '';
  };

  passthru.sources = { inherit linux; };

  meta = with lib; {
    inherit (pkgs.anki.meta) license homepage description longDescription;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ mahmoudk1000 ];
  };
in
  pkgs.buildFHSEnv (pkgs.appimageTools.defaultFhsEnvArgs // {
    inherit pname version;
    name = null;  # Appimage sets it to "appimage-env"

    targetPkgs = pkgs: (with pkgs; [
      xorg.libxkbfile
      xcb-util-cursor-HEAD
      krb5
    ]);

    runScript = pkgs.writeShellScript "anki-wrapper.sh" ''
      exec ${unpacked}/bin/anki ${ lib.strings.escapeShellArgs commandLineArgs } "$@"
    '';

    extraInstallCommands = ''
      ln -s ${pname} $out/bin/anki
      mkdir -p $out/share
      cp -R ${unpacked}/share/applications \
        ${unpacked}/share/man \
        ${unpacked}/share/pixmaps \
        $out/share/
    '';

    inherit meta passthru;
  })
