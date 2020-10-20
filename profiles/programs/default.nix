{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;

  inherit (builtins) map attrNames readDir;
  inherit (lib) filterAttrs hasSuffix;

  # List of all file configurations (subfolder/default.nix or thisfolder/file.nix)
  customPrograms = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));
in
{
  my.home = {
    imports = customPrograms;

    home.packages = with pkgs; lib.mkMerge [
      [
        ncdu
        element-desktop
        youtube-dl
      ]
      (lib.mkIf isLinux [
        fractal
        nwg-launchers
        bitwarden bitwarden-cli
        spotify
        signal-desktop
        chromium
        discord # unfortunately
        libreoffice
      ])
      (lib.mkIf isDarwin [
       
      ])
    ];
  };
}
