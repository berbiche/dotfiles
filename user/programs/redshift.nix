{ config, lib, pkgs, ... }:

{
  # Requires nixpkgs-wayland overlay
  home.packages = [ pkgs.redshift-wayland ];

  xdg.configFile."redshift/redshift.conf".text = ''
    [redshift]
    temp-day=6500
    temp-night=4000

    fade=1

    gamma-day=0.8:0.7:0.8
    gamma-night=0.6

    location-provider=geoclue2

    adjustment-method=wayland
  '';
}
