{ config, lib, pkgs, ... }:

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

  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux;
    [ libva ]
    ++ lib.optionals config.services.pipewire.enable [ pipewire ];

  home-manager.sharedModules = let
    version = "6.9-GE-2";
    proton-ge = fetchTarball {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
      sha256 = "0y8vv1lzbcbk328fn7kp79gn6k1jaj8yaxkd26vf5xnrncln71d7";
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
