{ config, lib, pkgs, ... }:

{
  my.identity.name = "Nicolas Berbiche";
  my.identity.email = "nic." + "berbiche" + "@" + "gmail" + ".com";

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
  };

  # HomeManager config
  # `man 5 home-configuration.nix`
  manual.manpages.enable = true;

  # XDG
  fonts.fontconfig.enable = lib.mkForce true;
  programs.emacs.enable = true;
}
