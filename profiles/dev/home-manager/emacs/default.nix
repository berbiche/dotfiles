{ config, lib, pkgs, inputs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  DOOMDIR = "${config.xdg.configHome}/doom";
in
lib.mkMerge [
  {
    # Extra packages that are already part of my config
    # won't be duplicated
    # Of course, all of these packages can be overriden
    # by direnv (envrc)
    home.packages = with pkgs; [
      # Nix
      nixfmt

      # C/cpp
      (lib.lowPrio clang-tools) # for clangd

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

    programs.emacs = {
      enable = true;
      package = lib.mkMerge [
        (lib.mkIf isLinux pkgs.emacsPgtk)
        (lib.mkIf isDarwin pkgs.emacsUnstable)
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
        patches = [ ./doom.d/disable_install_hooks.patch ];
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

    systemd.user.services.emacs = {
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session-pre.target" ];
      Install.WantedBy = lib.mkForce [ "graphical-session.target" ];
    };
  })
]
