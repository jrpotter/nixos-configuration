{ pkgs, lib, ... }:
let
  addons = id: "Anki2/addons21/${toString id}";

  anki-connect = pkgs.stdenv.mkDerivation {
    name = "anki-connect";

    src = pkgs.fetchFromGitea {
      domain = "git.foosoft.net";
      owner = "alex";
      repo = "anki-connect";
      rev = "2996476e03a86ea56fd8148e9a434d6f65af890a";
      hash = "sha256-5kwOZ6BLZqslBeOcX96GwLv3ME2J3czfw8oHG+ZgIQI=";
    };

    installPhase = ''
      mkdir -p $out
      cp -r ./plugin/* $out

      cat <<EOF > $out/meta.json
      {
        "name": "AnkiConnect",
        "mod": 1705874601,
        "min_point_version": 45,
        "max_point_version": 45,
        "branch_index": 1,
        "disabled": false
      }
      EOF

      cat <<EOF > $out/config.json
      {
        "apiKey": null,
        "apiLogPath": null,
        "webBindAddress": "127.0.0.1",
        "webBindPort": 8765,
        "webCorsOrigin": "http://localhost",
        "webCorsOriginList": [
          "http://localhost",
          "app://obsidian.md"
        ]
      }
      EOF
    '';
  };

  image-occlusion-enhanced = pkgs.stdenv.mkDerivation {
    name = "image-occlusion-enhanced";

    src = pkgs.fetchFromGitHub {
      owner = "glutanimate";
      repo = "image-occlusion-enhanced";
      rev = "33711026fbbfd0950fcfaee88ce776ab5e395f9b";
      hash = "sha256-aSe9IzezhV3MGW/KGcul+Eesa5oQVwisVse5tjr8RQc=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -r ./src/image_occlusion_enhanced/* $out

      cat <<EOF > $out/meta.json
      {
        "homepage": "https://github.com/glutanimate/image-occlusion-enhanced",
        "name": "Image Occlusion Enhanced",
        "max_point_version": 50,
        "mod": 1649488507,
        "conflicts": ["image_occlusion_enhanced"],
        "min_point_version": 50,
        "branch_index": 1,
        "disabled": false
      }
      EOF
    '';
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

      cat <<EOF > $out/meta.json
      {
        "mod": 1706379662,
        "name": "Syntax Highlighting NG",
        "homepage": "https://github.com/cav71/syntax-highlighting-ng",
        "conflicts": ["566351439", "syntax_highlighting"],
        "min_point_version": 49,
        "max_point_version": 231001,
        "branch_index": 0,
        "disabled": false
      }
      EOF

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
  # When deleting a plugin also remove the generated folder at
  # `$HOME/.local/share/Anki2/addons21`.
  xdg.dataFile = {
    "${addons 2055492159}" = {
      source = anki-connect;
      recursive = true;
    };
    "${addons 1374772155}" = {
      source = image-occlusion-enhanced;
      recursive = true;
    };
    "${addons 566351439}" = {
      source = syntax-highlighting-ng;
      recursive = true;
    };
  };

  home.packages = [
    (pkgs.callPackage ./bin.nix {})
  ];
}
