{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  # Of course, all of these packages can be overriden by direnv (envrc)
  home.packages = with pkgs; [
    # Erlang/Elixir
    erlang-ls
    # beamPackages.elixir beamPackages.elixir_ls

    # Go
    go gopls gocode gotools golangci-lint gore

    # Nix
    rnix-lsp nil nixfmt

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
}
