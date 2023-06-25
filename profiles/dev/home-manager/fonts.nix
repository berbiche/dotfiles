args@{ config, lib, pkgs, ... }:

let
  isStandalone = ! (args ? osConfig);
in
{
  fonts.fontconfig.enable = lib.mkDefault true;

  # Only install fonts on standalone HM installation
  # The fonts are already setup in the OS config
  home.packages = lib.mkIf isStandalone (with pkgs; [
    anonymousPro
    source-code-pro
    nerdfonts
    emacs-all-the-icons-fonts
  ]);
}
