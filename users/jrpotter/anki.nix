{ pkgs, ... }:
let
  FlexibleGrading = pkgs.fetchFromGitHub {
    owner = "jrpotter";
    repo = "FlexibleGrading";
    rev = "d9cd06bbb154a0740518e58e4619d3855e22c027";
    hash = "sha256-ciIVFyt7TDBeC+h5feA5I17Ld1Pge/hRDqGMMcLTJiM=";
    fetchSubmodules = true;
  };

  image-occlusion-enhanced = pkgs.fetchFromGitHub {
    owner = "glutanimate";
    repo = "image-occlusion-enhanced";
    rev = "33711026fbbfd0950fcfaee88ce776ab5e395f9b";
    hash = "sha256-aSe9IzezhV3MGW/KGcul+Eesa5oQVwisVse5tjr8RQc=";
  };

  syntax-highlighting-ng = pkgs.stdenv.mkDerivation {
    name = "syntax-highlighting-ng";
    src = pkgs.fetchgit {
      url = "https://github.com/cav71/syntax-highlighting-ng";
      rev = "138db00d5372e155ac056a148a5cd05a7455bfe1";
      hash = "sha256-2EEiS/wF2YcQf9U7rYxeWmgAluh5iUAE4fpron7JKw4=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r ./src/syntax_highlighting_ng/* $out
      cat <<EOF > $out/config.json
      {
        "hotkey": "Alt+s",
        "limitToLangs": [],
        "style": "monokai"
      }
      EOF
    '';
  };
in
{
  xdg.dataFile."Anki2/addons21/1715096333" = {
    source = FlexibleGrading;
    recursive = true;  # Let's addon write to directory.
  };

  xdg.dataFile."Anki2/addons21/1374772155".source =
    "${image-occlusion-enhanced}/src/image_occlusion_enhanced";

  xdg.dataFile."Anki2/addons21/566351439".source =
    syntax-highlighting-ng;

  home.packages = [ pkgs.anki-bin ];
}
