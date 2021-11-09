{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.steam.wine;

  wine-staging = pkgs.wineWowPackages.staging;
in
{
  options.profiles.steam.wine.enable = mkEnableOption "installing wine alongside Steam";

  config = mkIf cfg.enable {
    environment.systemPackages = [ wine-staging pkgs.winetricks ];
  };
}
