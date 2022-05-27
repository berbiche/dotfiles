{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  DOOMDIR = "${config.xdg.configHome}/doom";

  emacsWithPackages = package:
    (pkgs.emacsPackagesFor package).emacsWithPackages (epkgs: [
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
        (lib.mkIf isLinux (emacsWithPackages pkgs.emacsPgtk))
        (lib.mkIf isDarwin (emacsWithPackages pkgs.emacsUnstable))
      ];
    };

    home.sessionVariables = {
      inherit DOOMLOCALDIR DOOMDIR;
    };
    systemd.user.sessionVariables = lib.mkIf isLinux {
      inherit DOOMLOCALDIR DOOMDIR;
    };

    home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

    xdg.configFile."doom" = {
      source = ./doom.d;
      force = true;
    };

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
