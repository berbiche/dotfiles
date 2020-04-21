let
  rev = "57b7e1860a2f1d012f0f7193b310afb1622fad03";

  url = rec {
    # owner = "colemickens";
    # repo = "nixpkgs-wayland";
    # branch = "master";
    url = "https://github.com/colemickens/nixpkgs-wayland/archive/${rev}.tar.gz";
    sha256 = "18n6q2pzw25fk3crri4nhf3iyv3h16w17bbq4ampy8kdr3r56dgn";
  };
  waylandOverlay = (import (builtins.fetchTarball url));
in
waylandOverlay
