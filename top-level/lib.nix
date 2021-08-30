# Nixpkgs allows defining your own lib functions
{ pkgs, lib, isLinux, ... }:

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

  lib' = if isLinux then { lib.my = myLib; } else { };
in
lib' // {
  my.home = { config, ... }:  {
    lib.my = myLib // {
      getScript = name: "${config.home.file."scripts".source}/${name}";
    };
  };
}
