{ config, lib, pkgs, ... }:

{
  fonts.fontconfig.enable = lib.mkDefault true;

  home.packages = with pkgs; [
    anonymousPro
    source-code-pro
    nerdfonts
    emacs-all-the-icons-fonts
  ];
}
