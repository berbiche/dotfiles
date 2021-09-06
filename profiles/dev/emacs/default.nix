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
        # Extra packages that are already part of my config
        # won't be duplicated
        # Of course, all of these packages can be overriden
        # by direnv (envrc)
        home.packages = with pkgs; [
          # Nix
          nixfmt

          # C/cpp
          clang-tools # for clangd

          # Markdown exporting
          mdl pandoc

          # Python LSP setup
          # nodePackages.pyright
          # pipenv
          # (python3.withPackages (ps: with ps; [
          #   black isort pyflakes pytest
          # ]))

          # JavaScript
          # nodePackages.typescript-language-server

          # Bash
          nodePackages.bash-language-server shellcheck

          # Rust
          cargo cargo-audit cargo-edit clippy rust-analyzer rustfmt

          # Erlang and Elixir
          erlang-ls
          # beamPackages.elixir beamPackages.elixir_ls

          # Go
          go gocode goimports golangci-lint gore
        ];

        programs.doom-emacs = {
          enable = true;

          doomPrivateDir = ./doom.d;

          emacsPackage = lib.mkMerge [
            (lib.mkIf isLinux pkgs.emacsPgtk)
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
