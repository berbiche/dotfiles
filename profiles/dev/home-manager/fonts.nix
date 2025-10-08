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
    nerd-fonts.meslo-lg
    nerd-fonts.droid-sans-mono
    nerd-fonts.anonymice
    emacs-all-the-icons-fonts
  ]);
}
