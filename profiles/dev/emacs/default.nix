{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv) isDarwin isLinux system;

  doom-emacs = pkgs.callPackage inputs.doom-emacs {
    doomPrivateDir = ./doom.d;
    extraPackages = epkgs: [];
    # emacsPackages = pkgs.emacsPackages.overrideScope' (_: _: {
    #   emacs = pkgs.emacsGccPgtk;
    # });
    # I should pin the dependencies here
    # dependencyOverrides = ;
  };
in
lib.mkMerge [
  {
    my.home.imports = [ inputs.doom-emacs.hmModule ];
  }
  {
    my.home = { config, ... }: lib.mkMerge [
      {
        #home.packages = [ doom-emacs ];
        # xdg.configFile."emacs/init.el".text = ''
        #   (load "default.el")
        # '';

        # programs.emacs = {
        #   enable = true;
        #   package = doom-emacs;
        #   # package = pkgs.my-emacs-pgtk.emacs;
        # };
        programs.doom-emacs = {
          enable = true;
          doomPrivateDir = ./doom.d;
        };
      }
      # user systemd service for Linux
      (lib.optionalAttrs isLinux {
        services.emacs = {
          enable = true;
          client.enable = true;
          #socketActivation.enable = true;
        };
      })
    ];
  }
  # Darwin launchd service for Emacs
  (lib.mkIf isDarwin { services.emacs.enable = true; })
]
