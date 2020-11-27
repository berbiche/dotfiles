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
  waybar = (prev.waybar.override { inherit fmt; }).overrideAttrs (_: rec {
    version = "faacd76f627f4f7ad3413a44870e089fbdb6539e";
    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = version;
      hash = "sha256-4DsOp25b5Z3vHw4j5LnQcvVdh+vrM9JpOJdY/JhKawk=";
    };
  });
}
