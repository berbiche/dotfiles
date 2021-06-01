{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv) isDarwin isLinux;

  enableWakaTime = config.profiles.dev.wakatime.enable;

  overrides = eself: esuper: { };
in
lib.mkMerge [
  {
    my.home = lib.mkMerge [
      { imports = [ inputs.doom-emacs.hmModule ]; }
      {
        programs.doom-emacs = {
          enable = true;
          doomPrivateDir = ./doom.d;
          # emacsPackage = pkgs.emacsGccPgtk;
          emacsPackage = lib.mkMerge [
            # (lib.mkIf isLinux pkgs.emacsPgtkGcc)
            (lib.mkIf isLinux pkgs.emacsPgtk)
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
