{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
  # inherit (config.my.dev) beamPackages;
in {
  options.my.dev.beamPackages = lib.mkOption {
    type = lib.types.attrsOf lib.types.raw;
    description = "extensible attrsset of beamPackages to use";
  };

  config = {
    # my.dev.beamPackages = pkgs.beamPackages.extend (final: prev: {
    #   # erlang = pkgs.erlang_27;
    #   # elixir = prev.elixir_1_17.override { erlang = final.erlang; };
    #   # elixir = final.elixir_1_18;
    #   # erlang-ls = prev.erlang-ls.overrideAttrs { doCheck = false; };
    #   # elixir-ls = prev.elixir-ls.override { elixir = final.elixir; };
    #   # The test suite does not run in parallel and is very slow
    #   # ...so just skip it
    #   # rebar3 = prev.rebar3.overrideAttrs (_drv: {
    #   #   doCheck = false;
    #   # });
    #   # rebar3WithPlugins = args: prev.rebar3WithPlugins (args // { rebar3 = final.rebar3; });
    # });

    # Of course, all of these packages can be overriden by direnv (envrc)
    home.packages = with pkgs;
      [
        ## Erlang/Elixir
        beamPackages.erlang
        erlang-language-platform
        beamPackages.rebar3
        beamPackages.elixir
        # beamPackages.elixir-ls
        beamPackages.expert

        ## Go
        go
        gopls
        (lib.hiPrio gotools)
        golangci-lint
        gore

        ## Nix
        nil
        nixfmt

        ## Shell
        bash-language-server
        shellcheck

        # Not sure
        diagnostic-languageserver

        ## Typescript
        typescript-language-server

        ## Docker
        dockerfile-language-server

        ### Python LSP setup
        # pipenv
        # (python3.withPackages (ps: with ps; [
        #   black isort pyflakes pytest
        # ]))
        pyright

        ### Rust
        # rust-analyzer
        # cargo
        # cargo-audit
        # cargo-edit
        # clippy
        # rustfmt

        # YAML
        yaml-language-server
        # JSON, HTML, CSS    (I only care about JSON)
        vscode-langservers-extracted
      ] ++ lib.optionals isLinux [
        ## Vala
        vala-language-server
      ] ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") [
        # For clangd
        (lib.lowPrio clang-tools)
      ];
  };
}
