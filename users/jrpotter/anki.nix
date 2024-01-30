{ pkgs, ... }:
let
  addons = id: "Anki2/addons21/${toString id}";

  FlexibleGrading = pkgs.fetchFromGitHub {
    owner = "jrpotter";
    repo = "FlexibleGrading";
    rev = "d9cd06bbb154a0740518e58e4619d3855e22c027";
    hash = "sha256-ciIVFyt7TDBeC+h5feA5I17Ld1Pge/hRDqGMMcLTJiM=";
    fetchSubmodules = true;
  };

  anki-connect = pkgs.fetchFromGitea {
    domain = "git.foosoft.net";
    owner = "alex";
    repo = "anki-connect";
    rev = "2996476e03a86ea56fd8148e9a434d6f65af890a";
    hash = "sha256-5kwOZ6BLZqslBeOcX96GwLv3ME2J3czfw8oHG+ZgIQI=";
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
  xdg.dataFile = {
    "${addons 1715096333}" = {
      source = FlexibleGrading;
      recursive = true;  # Let's addon write to directory.
    };

    "${addons 2055492159}".source =
      "${anki-connect}/plugin";

    "${addons 1374772155}".source =
      "${image-occlusion-enhanced}/src/image_occlusion_enhanced";

    "${addons 566351439}".source =
      syntax-highlighting-ng;
  };

  home.packages = [ pkgs.anki-bin ];
}
