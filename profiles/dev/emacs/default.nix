{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv) isDarwin isLinux;

  # overrides = eself: esuper: rec {
  #   auctex = esuper.auctex.overrideAttrs (old: {
  #     src = pkgs.fetchurl {
  #       # The generated url is wrong, it needs a ".lz"
  #       url = "https://elpa.gnu.org/packages/auctex-${old.version}.tar.lz";
  #       sha256 = old.src.outputHash;
  #     };
  #   });
  #   # elpaPackages.auctex = auctex;
  # };
  overrides = eself: esuper: { };
in
lib.mkMerge [
  {
    my.home.imports = [ inputs.doom-emacs.hmModule ];
  }
  {
    my.home = lib.mkMerge [
      {
        programs.doom-emacs = {
          enable = true;
          doomPrivateDir = ./doom.d;
          # emacsPackage = pkgs.emacsGccPgtk;
          emacsPackage = lib.mkMerge [
            (lib.mkIf isLinux pkgs.emacs-pgtk)
            (lib.mkIf isDarwin pkgs.emacs)
          ];
          emacsPackagesOverlay = overrides;
          extraPackages = with pkgs; [
            (hunspellWithDicts [
              "en_CA-large"
              "fr-any"
            ])
          ];
          extraConfig = ''
            (setq ispell-program-name "hunspell")
          '';
        };
      }
      # user systemd service for Linux
      (lib.optionalAttrs isLinux {
        services.emacs = {
          enable = true;
          # The client is already provided by the Doom Emacs final package
          client.enable = false;
        };
      })
    ];
  }
  # Darwin launchd service for Emacs
  (lib.mkIf isDarwin { services.emacs.enable = true; })
]
