{ config, pkgs, lib, ... }:

# Uses nix-darwin modules
let
  profiles = import ../profiles;
in
{
  imports = with profiles; [ dev programs ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix = {
    useSandbox = true;
    sandboxPaths = [ "/System/Library/Frameworks" "/System/Library/PrivateFrameworks" "/usr/lib" "/private/tmp" "/private/var/tmp" "/usr/bin/env" ];
    trustedUsers = [ "@admin" ];
  };

  # This is a single-user Nix install
  services.nix-daemon.enable = lib.mkForce false;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  services.emacs.enable = true;

  # Fix xdg.{dataHome,cacheHome} being empty in home-manager
  users.users.${config.my.username} = {
    home = "/Users/${config.my.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };
}
