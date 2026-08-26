# Direnv replacement (ish)
{ pkgs, ... }:

{
  home.packages = [ pkgs.devenv ];
  programs.fish.shellInit = ''
    ${pkgs.devenv}/bin/devenv hook fish | source
  '';
}
