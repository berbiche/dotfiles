{ config, lib, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/pull/86480
{
  imports = [ ./wine.nix ];

  programs.steam.enable = true;

  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.steam.override {
        extraPkgs = pkgs: with pkgs; [ mono gtk3 gtk3-x11 libgdiplus zlib ];
        # nativeOnly = true;
      };
    })
  ];

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux;
    [ libva ]
    ++ lib.optionals config.services.pipewire.enable [ pipewire ];

  home-manager.sharedModules = let
    version = "6.14-GE-2";
    proton-ge = fetchTarball {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
      sha256 = "sha256:18hfag1nzj6ldy0ign2yjfzfms0w23vmcykgl8h1dfk0xjaql8gk";
    };
  in [
    {
      home.file.proton-ge-custom = {
        recursive = true;
        source = proton-ge;
        target = ".steam/root/compatibilitytools.d/Proton-${version}";
      };
    }
  ];
}
