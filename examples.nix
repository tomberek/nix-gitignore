with (import <nixpkgs> {});

let
  nixgitignoreLocal = import ./. { inherit lib; };
  nixgitignoreGithub = import (pkgs.fetchFromGitHub {
    owner = "siers";
    repo = "nix-gitignore";
    rev = "c7580241aed2ab126ca3daeee21e6096a3a08b18";
    sha256 = "1dx3m7r4hlmrv65ik6j30r6zyif0r5v29ycklrz3pw58vnplngdf";
  }) { inherit lib; };
in
  with nixgitignoreGithub;

let
  # an example to get a rough feel of what the filterPattern does
  sourcePat = builtins.filterSource (filterPattern [
    ["^1.*/2$"  false]
    ["^2.*/30$" true]
    ["^2.*/.*"  false]
  ] ./test-tree ) ./test-tree;

  sourceGit = builtins.filterSource (gitignoreFilter ''
      1-simple/1
      /1-simple/2
      ^1-simple/3

      !2-*/1?
      !2-*/30
      !/40
      !50
      2-*/*

      3-*/*foo.html
      3-*/**/bar.html

      4-*/\*.html
      4-*/o??ther.html
      4-*/o\?ther.html
      4-*/other.html$
    '' ./test-tree) ./test-tree;

in
  [ sourcePat sourceGit ]
