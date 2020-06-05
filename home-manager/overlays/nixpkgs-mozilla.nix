let
  revision = "master";
  mozilla-overlay = import (builtins.fetchTarball "https://github.com/mozilla/nixpkgs-mozilla/archive/${revision}.tar.gz");
in
mozilla-overlay
