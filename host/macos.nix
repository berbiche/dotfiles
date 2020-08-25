{ config, pkgs, ... }:

# Uses nix-darwin modules
{
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix = {
    useSandbox = true;
    sandboxPaths = [ "/System/Library/Frameworks" "/System/Library/PrivateFrameworks" "/usr/lib" "/private/tmp" "/private/var/tmp" "/usr/bin/env" ];
    trustedUsers = [ "@admin" ];
  };

  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.nerdfonts ];
  };

  programs.fish.enable = true;
}
