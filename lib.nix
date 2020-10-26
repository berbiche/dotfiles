# Nixpkgs allows defining your own lib functions
{ pkgs, ... }:

with builtins;

let
  myLib = {
    # `callPackage` equivalent without the makeOverridable part
    # Useful to import a file that expects many dependencies
    callWithDefaults = fn: args:
      let
        f = if isFunction fn then fn else import fn;
        auto = intersectAttrs (functionArgs f) pkgs;
      in f (auto // args);
  };
in
{
  lib = myLib;
  my.home = { config, ... }:  {
    lib.my = myLib // {
      getScript = name: "${config.home.file."scripts".source}/${name}";
    };
  };
}
