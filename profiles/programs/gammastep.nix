{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
in
lib.mkIf isLinux {
  # Requires nixpkgs-wayland overlay
  services.redshift = {
    enable = false;
    # 
    package = pkgs.redshift;
    # Some options cannot be configured through the command line (gamma-day, gamma-night, fade)
    extraOptions = [ "-c ${config.xdg.configHome}/redshift/redshift.conf" ];
    tray = true;
    provider = "geoclue2";
  };

  # Requires nixpkgs-wayland overlay
  home.packages = [ pkgs.gammastep ];

  xdg.configFile."gammastep/config.ini".text = ''
    [general]
    temp-day=6500
    temp-night=4000

    fade=1

    gamma-day=0.8:0.7:0.8
    gamma-night=0.6

    location-provider=geoclue2

    adjustment-method=wayland
  '';
}
