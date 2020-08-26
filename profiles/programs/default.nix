{ config, lib, pkgs, ... }:

let
  # Requires --impure build
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isDarwin isLinux;

  inherit (builtins) map attrNames readDir;
  inherit (lib) filterAttrs hasSuffix;

  # List of all file configurations (subfolder/default.nix or thisfolder/file.nix)
  customPrograms = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));
in
{
  home-manager.users.${config.my.username} = {
    imports = customPrograms;

    home.packages = with pkgs; [
      ncdu
      element-desktop
      youtube-dl
    ] ++ (lib.optionals isLinux [
      bitwarden bitwarden-cli
      spotify
      signal-desktop
      chromium
      discord # unfortunately
      libreoffice
    ]) ++ (lib.optionals isDarwin [
     
    ]);
  };
}
