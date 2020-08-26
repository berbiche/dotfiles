{ config, lib, pkgs, ... }:

let
  inherit (builtins) map attrNames readDir import;
  inherit (lib) filterAttrs hasSuffix;

  # Import all programs under ./programs using their default.nix
  customPrograms = let
    files = readDir ./.;
    filtered = filterAttrs (n: v: n != "default.nix" && (v == "directory" || (v == "regular" && hasSuffix ".nix" n)));
  in map (p: ./. + "/${p}") (attrNames (filtered files));

  # Requires --impure build
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isDarwin isLinux;
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
    ]) ++ (lib.optionals isDarwin [
     
    ]);
  };
}
