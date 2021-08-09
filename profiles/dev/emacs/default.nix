{ config, pkgs, inputs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  enableWakaTime = config.profiles.dev.wakatime.enable;
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
            # The `passthru` attribute is somehow missing...
            (lib.mkIf isLinux pkgs.emacsPgtkGcc)
            (lib.mkIf isDarwin pkgs.emacs)
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
          Unit.After = [ "graphical-session-pre.target" ];
          Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
        };
      })
    ];
  }
  # Darwin launchd service for Emacs
  (lib.mkIf isDarwin { services.emacs.enable = true; })
]
