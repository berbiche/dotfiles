final: prev:

let
  inherit (prev) lib;
in
{
  # `callPackage` without the override/overridable
  callWithDefaults = fn: args:
    let
      f = if lib.isFunction fn then fn else import fn;
      auto = builtins.intersectAttrs (lib.functionArgs f) prev;
    in f (auto // args);
}
