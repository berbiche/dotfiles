self: super:
let
  inherit (super) lib;
  overlaysDir = ./overlays;
  allOverlays = lib.pipe (builtins.readDir overlaysDir) [
    (lib.filterAttrs (f: v: v == "regular" && lib.hasSuffix ".nix" f && f != "default.nix"))
    (lib.mapAttrsToList (f: _: import (overlaysDir + "/${f}")))
  ];

  # https://discourse.nixos.org/t/infinite-recursion-when-composing-overlays/7594/8
  overlays = lib.foldl' lib.composeExtensions (_: _: { }) allOverlays;
in
overlays self super
