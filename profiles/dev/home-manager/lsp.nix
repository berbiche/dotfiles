{ config, lib, pkgs, ... }:

{
  # Of course, all of these packages can be overriden by direnv (envrc)
  home.packages = with pkgs; [
    # For clangd
    (lib.lowPrio clang-tools)

    # Erlang/Elixir
    erlang-ls
    # beamPackages.elixir beamPackages.elixir_ls

    # Go
    go gocode goimports golangci-lint gore

    # Nix
    nixfmt

    # Shell
    nodePackages.bash-language-server shellcheck

    # Not sure
    nodePackages.diagnostic-languageserver

    # Typescript
    nodePackages.typescript-language-server

    # Python LSP setup
    # pipenv
    # (python3.withPackages (ps: with ps; [
    #   black isort pyflakes pytest
    # ]))
    pyright
    # Rust
    rnix-lsp
    rust-analyzer
    cargo cargo-audit cargo-edit clippy
    rustfmt
    # Vala
    vala-language-server
    # YAML
    yaml-language-server
  ];
}
