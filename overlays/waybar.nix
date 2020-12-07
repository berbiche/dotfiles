final: prev:
let
  fmt = prev.fmt.overrideAttrs (_: rec {
    version = "7.0.3";
    src = prev.fetchFromGitHub {
      owner = "fmtlib";
      repo = "fmt";
      rev = version;
      hash = "sha256-Ks3UG3V0Pz6qkKYFhy71ZYlZ9CPijO6GBrfMqX5zAp8=";
    };
  });
in
{
  waybar = prev.waybar.override { inherit fmt; };
}
