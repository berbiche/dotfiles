{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  DOOMDIR = "${config.xdg.configHome}/doom";
  DOOMPROFILELOADFILE = "${config.xdg.dataHome}/doom/cache/profile-load.el";

  emacsWithPackages = package:
    (pkgs.emacsPackagesFor (
      # package.overrideAttrs (drv: { noTreeSitter = false; nativeComp = true; })
      package.override (drv: { withTreeSitter = true; withNativeCompilation = true; })
    )).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]);
in
lib.mkMerge [
  {
    home.packages = with pkgs; [
      # Markdown exporting
      mdl pandoc
    ];

    programs.emacs = {
      enable = true;
      package = lib.mkMerge [
        (lib.mkIf isLinux (emacsWithPackages pkgs.emacs29-pgtk))
        (lib.mkIf isDarwin (emacsWithPackages pkgs.emacs29))
      ];
    };

    home.sessionVariables = {
      inherit DOOMLOCALDIR DOOMDIR DOOMPROFILELOADFILE;
    };
    systemd.user.sessionVariables = lib.mkIf isLinux {
      inherit DOOMLOCALDIR DOOMDIR DOOMPROFILELOADFILE;
    };

    home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

    xdg.configFile."doom" = {
      source = pkgs.applyPatches {
        name = "doom-emacs-dotfiles";
        src = ./doom.d;
        patches = [
          (pkgs.substituteAll {
            src = ./doom.d/envrc-package.patch;
            envrc_direnv_package = "${config.programs.direnv.package or pkgs.direnv}/bin/direnv";
          })
        ];
      };
      force = true;
    };

    # Create this folder for the $DOOMPROFILELOADFILE file
    xdg.dataFile."doom/cache/.keep".text = "";

    xdg.configFile."emacs" = {
      source = pkgs.applyPatches {
        name = "doom-emacs-source";
        src = inputs.doom-emacs-source;
        # No longer necessary since https://github.com/hlissner/doom-emacs/commit/1c1ad3a8c8b669b6fa20b174b2a4c23afa85ec24
        # Just pass "--no-hooks" when installing Doom Emacs
        # patches = [ ./doom.d/disable_install_hooks.patch ];
      };
      force = true;
    };
  }
  # user systemd service for Linux
  (lib.mkIf isLinux {
    services.emacs = {
      enable = true;
      # The client is already provided by the Doom Emacs final package
      client.enable = false;
    };

    # Only start after graphical session because of missing DISPLAY/WAYLAND_DISPLAY
    # environment variable
    # systemd.user.services.emacs = {
    #   Unit.PartOf = [ "graphical-session.target" ];
    #   Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    # };
  })
]
