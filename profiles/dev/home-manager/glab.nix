{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.glab ];
  # programs.glab = {
  #   enable = true;
  # };
  # programs.gh = {
  #   enable = true;
  #   settings.git_protocol = "ssh";
  #   # prompt = "enabled";
  #   settings.aliases = {
  #     aliases = "alias list";
  #     co = "pr checkout";
  #     pv = "pr view";
  #     prc = "pr create";
  #     # Mnemonic: pr mine
  #     prm = "pr list --author=berbiche";
  #     # Create a repo for my user
  #     rc = ''!gh repo create "''${PWD##*/}" "$@"'';
  #     rcl = "repo clone";
  #   };
  # };
}
