{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv) isDarwin isLinux;
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
          emacsPackage = pkgs.emacs-pgtk;
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
