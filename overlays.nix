final: pkgs:
let
  inherit (pkgs) lib;
  overlaysDir = ./overlays;
  allOverlays = (lib.pipe (builtins.readDir overlaysDir) [
    (lib.filterAttrs (f: v: v == "regular" && lib.hasSuffix ".nix" f && f != "default.nix"))
    (lib.mapAttrsToList (f: _: import (overlaysDir + "/${f}")))
  ]) ++ [(
    final: pkgs: {
      # `callPackage` without the override/overridable
      callWithDefaults = fn: args:
        let
          f = if lib.isFunction fn then fn else import fn;
          auto = builtins.intersectAttrs (lib.functionArgs f) pkgs;
        in f (auto // args);
    }
  )];

  # https://discourse.nixos.org/t/infinite-recursion-when-composing-overlays/7594/8
  overlays = lib.foldl' lib.composeExtensions (_: _: { }) allOverlays;
in
overlays final pkgs
