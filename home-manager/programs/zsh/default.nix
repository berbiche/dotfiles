{ config, lib, pkgs, ... }:

let
  zshDotDir = "${config.xdg.configHome}/zsh";
in
{
  #programs.zsh.ohMyZsh.theme = 'powerlevel10k/powerlevel10k';
  programs.zsh = {
    enable = true;
    # enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = zshDotDir;
    history.expireDuplicatesFirst = true;
    history.ignoreDups = false;
    history.path = "${config.xdg.cacheHome}/zsh/history";
    history.share = false;
    history.size = 100000;
    history.save = 100000;

    initExtra = lib.fileContents ./.zshrc;
    envExtra = lib.fileContents ./.zshenv;
    profileExtra = lib.fileContents ./.zprofile;
  };

  xdg.configFile."zsh/base-zshrc".source = ./base-zshrc;
  xdg.configFile."zsh/zaliases".source = ./zaliases;
}
