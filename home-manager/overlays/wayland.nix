let
  #rev = "57b7e1860a2f1d012f0f7193b310afb1622fad03";
  rev = "master";
  url = "https://github.com/colemickens/nixpkgs-wayland/archive/${rev}.tar.gz";
  waylandOverlay = (import (builtins.fetchTarball url));
in
waylandOverlay
