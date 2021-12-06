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
  imports = [ ];

  my.home = {
    imports = customPrograms;

    home.packages = with pkgs; lib.mkMerge [
      [
        element-desktop
        yt-dlp
      ]
      (lib.mkIf isLinux [
        fractal
        evince
        nwg-launchers
        bitwarden bitwarden-cli
        spotify
        signal-desktop
        chromium
        libreoffice
      ])
      (lib.mkIf isDarwin [

      ])
    ];
  };
}
