{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  enableWakaTime = config.profiles.dev.wakatime.enable;

  overrides = eself: esuper: rec {
    # project = esuper.project.overrideAttrs (_: {
    #     version = "0.6.0";
    #     elpaBuild = super.elpaBuild
    #     src = pkgs.fetchurl {
    #       url = "https://elpa.gnu.org/packages/project-0.6.0.tar";
    #       sha256 = "0m0r1xgz1ffx6mi2gjz1dkgrn89sh4y5ysi0gj6p1w05bf8p0lc0";
    #     };
    # });
    #elpaPackages = esuper.elpaPackages // { inherit project; };
    #melpaPackages = esuper.melpaPackages // { inherit project; };
  };
in
lib.mkMerge [
  {
    my.home = lib.mkMerge [
      { imports = [ inputs.doom-emacs.hmModule ]; }
      {
        programs.doom-emacs = {
          enable = true;
          doomPrivateDir = ./doom.d;
          emacsPackage = lib.mkMerge [
            (lib.mkIf isLinux pkgs.emacsPgtkGcc)
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
            ${lib.optionalString enableWakaTime ''
              (global-wakatime-mode t)
              (setq wakatime-cli-path "${pkgs.wakatime}/bin/wakatime")
            ''}
          '';
        };
      }
      # user systemd service for Linux
      (lib.mkIf isLinux {
        services.emacs = {
          enable = true;
          # The client is already provided by the Doom Emacs final package
          client.enable = false;
        };

        systemd.user.services.emacs = {
          Unit.PartOf = [ "graphical-session.target" ];
          Unit.After = [ "graphical-session.target" ];
          Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
      })
    ];
  }
  # Darwin launchd service for Emacs
  (lib.mkIf isDarwin { services.emacs.enable = true; })
]
