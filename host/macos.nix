{ config, pkgs, ... }:

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

  services.nix-daemon.enable = true;

  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.nerdfonts ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;
  services.emacs.enable = true;
}
