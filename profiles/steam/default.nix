{ config, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/pull/86480
{
  programs.steam.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override {
        extraPkgs = pkgs: with pkgs; [ mono gtk3 gtk3-x11 libgdiplus zlib ];
        # nativeOnly = true;
      };
    })
  ];

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
}
