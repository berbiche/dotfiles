{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix = {
    sandboxPaths = [ "/System/Library/Frameworks" "/System/Library/PrivateFrameworks" "/usr/lib" "/private/tmp" "/private/var/tmp" "/usr/bin/env" ];
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;
  services.emacs.enable = true;

  # Fix xdg.{dataHome,cacheHome} being empty in home-manager
  users.users.${config.my.username} = {
    home = "/Users/${config.my.username}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  profiles.dev.wakatime.enable = lib.mkForce false;

  users.nix.configureBuildUsers = true;

  services.nix-daemon.enable = true;

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = true;
    FXEnableExtensionChangeWarning = false;
  };

  system.defaults.dock = {
    expose-group-by-app = true;
    minimize-to-application = true;
    mru-spaces = false;
    orientation = "right";
    show-recents = false;
    tilesize = 48;
  };

  system.defaults.loginwindow = {
    # SHOWFULLNAME = false;
    GuestEnabled = false;
    LoginwindowText = "Property of Nicolas Berbiche";
    # DisableConsoleAccess = true;
  };

  system.defaults.NSGlobalDomain = {
    AppleKeyboardUIMode = 3;
    AppleShowAllExtensions = with config.system.defaults.finder;
      if isNull AppleShowAllExtensions then false else AppleShowAllExtensions;
    AppleShowScrollBars = "Always";
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    InitialKeyRepeat = 25;
    KeyRepeat = 2;
    "com.apple.keyboard.fnState" = true;
    "com.apple.mouse.tapBehavior" = 1;
  };

  system.activationScripts.preUserActivation.text = ''
    mkdir -p ~/Screenshots
  '';
  system.defaults.screencapture.location = "${config.users.users.${config.my.username}.home}/Screenshots";

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };
}
