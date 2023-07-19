{ config, lib, pkgs, ... }:

{
  # ctrl-t, ctrl-r, kill <tab><tab>
  programs.fzf = {
    enable = true;
    defaultCommand = ''${pkgs.fd}/bin/fd --strip-cwd-prefix -H --follow --type f --exclude=".git"'';
    defaultOptions = [ "--exact" "--cycle" "--layout=reverse" ];
    fileWidgetCommand = config.programs.fzf.defaultCommand;
  };
}
