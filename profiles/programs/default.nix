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

  my.home = {config, ...}: let
    homeCfg = config;
  in {
    imports = customPrograms;

    home.packages = with pkgs; lib.mkMerge [
      (lib.mkIf (!homeCfg.my.config.is-work-host) [
        element-desktop
        yt-dlp
      ])
      (lib.mkIf (isLinux && !homeCfg.my.config.is-work-host) [
        fractal
        evince
        nwg-launchers
        bitwarden bitwarden-cli
        spotify
        signal-desktop
        libreoffice
      ])
      (lib.mkIf isDarwin [

      ])
    ];
  };
}
