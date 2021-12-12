{ config, lib, pkgs, ... }:

# https://github.com/NixOS/nixpkgs/pull/86480
{
  imports = [ ./wine.nix ];

  programs.steam.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.driSupport = true;

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
    version = "6.21-GE-2";
    proton-ge = fetchTarball {
      url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
      sha256 = "sha256:0j39i19m1djkc0g1a4jq4bhihyz9rn2s4rk46rgqyvvd80rdky71";
    };
  in [
    ({ config, lib, pkgs, ... }: {
      options.profiles.steam.enableProtonGE = lib.mkEnableOption "using Proton-Ge-Custom";

      config = lib.mkIf config.profiles.steam.enableProtonGE {
        home.activation.proton-ge-custom = ''
          if [ ! -d "$HOME/.steam/root/compatibilitytools.d/Proton-${version}" ]; then
            cp -rsv ${proton-ge} "$HOME/.steam/root/compatibilitytools.d/Proton-${version}"
          fi
        '';
      };
      # home.file.proton-ge-custom = {
      #   recursive = true;
      #   source = proton-ge;
      #   target = ".steam/root/compatibilitytools.d/Proton-${version}";
      # };
    })
  ];
}
