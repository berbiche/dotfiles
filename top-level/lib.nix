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
      toPath = map (x: directory + "/${x}");
    in
      assert isPath directory;
      if pathExists directory then
        toPath (attrNames files)
      else [];

  # Returns a list of nix files in the directory without recursing (and without `default.nix`)
  myLib.nixFilesInDir = directory:
    libprev.filter (n: libprev.hasSuffix "nix" n && n != "default.nix") (libprev.myLib.filesInDir directory);
})
