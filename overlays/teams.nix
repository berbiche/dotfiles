final: prev: let
  nixpkgs = import (prev.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "b4a61b636a21c7e4608ae9003ccb3865176f395c";
    hash = "sha256-wqb0YsepoPLtFhkCef1U8lErzSoDCApIEELiKV0a3cw=";
  }) {
    inherit (prev) config system;
  };
in {
  inherit (nixpkgs) teams;
}
