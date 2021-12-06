{ config, lib, pkgs, ... }:

{
  # ctrl-t, ctrl-r, kill <tab><tab>
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    defaultCommand = ''${pkgs.fd}/bin/fd --follow --type f --exclude=".git" .'';
    defaultOptions = [ "--exact" "--cycle" "--layout=reverse" ];
  };
}
