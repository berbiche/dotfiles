{ pkgs, lib }:

with builtins;

lib.extend (libfinal: libprev: {
  # `callPackage` equivalent without the makeOverridable part
  # Useful to import a file that expects many dependencies
  myLib.callWithDefaults = fn: args:
    let
      f = if isFunction fn then fn else import fn;
      auto = intersectAttrs (functionArgs f) pkgs;
    in f (auto // args);

  # Returns a list of files in the directory without recursing
  myLib.filesInDir = directory:
    let
      files = readDir directory;
      filteredFiles = libprev.filterAttrs (n: v: libprev.hasSuffix "nix" n && n != "default.nix") files;
      toPath = map (x: directory + "/${x}");
    in
      assert isPath directory;
      if pathExists directory then
        toPath (attrNames filteredFiles)
      else [];
})
