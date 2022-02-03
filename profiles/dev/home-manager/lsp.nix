{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    pyright
    yaml-language-server
    erlang-ls
    nodePackages.bash-language-server
    nodePackages.diagnostic-languageserver
    # For clangd
    (lib.lowPrio clang-tools)
    nodePackages.typescript-language-server
    rnix-lsp
    rust-analyzer
    shellcheck
  ];
}
