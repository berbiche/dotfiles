{ config, pkgs, lib, ... }:

{
  imports = [
    ./homebrew.nix
  ];

  environment.shells = [ pkgs.fish pkgs.zsh ];

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
    expose-group-by-app = true;
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
    AppleShowAllExtensions = with config.system.defaults.finder;
      if isNull AppleShowAllExtensions then false else AppleShowAllExtensions;
    AppleShowScrollBars = "Always";
    ApplePressAndHoldEnabled = false;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    InitialKeyRepeat = 25;
    KeyRepeat = 2;
    "com.apple.keyboard.fnState" = false;
    "com.apple.mouse.tapBehavior" = 1;
  };

  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDayOfWeek = true;
    ShowDate = 2;
  };

  system.defaults.screencapture.location = "${config.users.users.${config.my.username}.home}/Screenshots";

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.safari"."ShowFullURLInSmartSearchField" = true;
  };


  # Symlink Home Manager apps to ~/Applications/Home\ Manager\ Apps
  # for Raycast (spotlight alternative)
  my.home = { config, pkgs, ... }: {
    home.file."Applications/Home Manager Apps".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in "${apps}/Applications";

    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
