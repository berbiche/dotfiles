{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  inherit (config.my.dev) beamPackages;
in
{
  options.my.dev.beamPackages = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    description = "extensible attrsset of beamPackages to use";
  };

  config = {
    my.dev.beamPackages = pkgs.beamPackages.extend (final: prev: {
      erlang = pkgs.erlang_26;
      elixir = prev.elixir_1_15;
      erlang-ls = prev.erlang-ls.overrideAttrs { doCheck = false; };
      elixir-ls = prev.elixir-ls.override { elixir = final.elixir; };
      # The test suite does not run in parallel and is very slow
      # ...so just skip it
      rebar3 = prev.rebar3.overrideAttrs (_drv: {
        doCheck = false;
      });
      rebar3WithPlugins = args: prev.rebar3WithPlugins (args // { rebar3 = final.rebar3; });
    });

    # Of course, all of these packages can be overriden by direnv (envrc)
    home.packages = with pkgs; [
      # Erlang/Elixir
      beamPackages.erlang beamPackages.erlang-ls beamPackages.rebar3
      beamPackages.elixir beamPackages.elixir-ls

      # Go
      go gopls gotools golangci-lint gore

      # Nix
      nil nixfmt-classic

      # Shell
      nodePackages.bash-language-server shellcheck

      # Not sure
      nodePackages.diagnostic-languageserver

      # Typescript
      nodePackages.typescript-language-server

      # Docker
      nodePackages.dockerfile-language-server-nodejs

      # Python LSP setup
      # pipenv
      # (python3.withPackages (ps: with ps; [
      #   black isort pyflakes pytest
      # ]))
      pyright
      # Rust
      rust-analyzer
      cargo cargo-audit cargo-edit clippy
      rustfmt
      # YAML
      yaml-language-server
      # JSON, HTML, CSS    (I only care about JSON)
      nodePackages.vscode-langservers-extracted
    ]
    ++ lib.optionals isLinux [
      # Vala
      vala-language-server
    ]
    ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") [
      # For clangd
      (lib.lowPrio clang-tools)
    ];
  };
}
