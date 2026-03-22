{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./homebrew.nix ];

  environment.shells = [
    pkgs.fish
    pkgs.zsh
  ];

  # Fix xdg.{dataHome,cacheHome} being empty in home-manager
  users.users.${config.my.username} = {
    home = "/Users/${config.my.username}";
    isHidden = false;
    shell = pkgs.fish;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = true;
    FXEnableExtensionChangeWarning = false;
    CreateDesktop = false;
  };

  system.defaults.dock = lib.mkDefault {
    expose-group-apps = true;
    minimize-to-application = true;
    mru-spaces = false;
    orientation = "bottom";
    show-recents = true;
    tilesize = 48;
  };

  system.defaults.loginwindow = {
    # SHOWFULLNAME = false;
    GuestEnabled = false;
    # DisableConsoleAccess = true;
  };

  system.defaults.NSGlobalDomain = {
    AppleKeyboardUIMode = 3;
    AppleShowAllExtensions =
      with config.system.defaults.finder;
      if isNull AppleShowAllExtensions then false else AppleShowAllExtensions;
    AppleShowScrollBars = "Always";
    ApplePressAndHoldEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    InitialKeyRepeat = 10;
    KeyRepeat = 2;
    "com.apple.keyboard.fnState" = false;
    "com.apple.mouse.tapBehavior" = 1;
  };

  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDayOfWeek = true;
    ShowDate = 2;
  };

  system.defaults.screencapture.location = "${
    config.users.users.${config.my.username}.home
  }/Screenshots";

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
  };

  my.home =
    { config, pkgs, ... }:
    {
      home.sessionPath = [ "$HOME/.local/bin" ];
    };
}
