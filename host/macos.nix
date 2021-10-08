{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix.maxJobs = 6;

  environment.systemPackages = [ pkgs.vagrant ];

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

  system.defaults.screencapture.location = "${config.users.users.${config.my.username}.home}/Screenshots";

  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };

  homebrew.enable = true;
  homebrew.brewPrefix = "/usr/local/Homebrew/bin";
  homebrew.brews = [
    "lsusb"
    "pinentry"
    "pinentry-mac"
  ];
  homebrew.casks = [
    "alt-tab"
    "caffeine"
    "hiddenbar"
    "karabiner-elements"
    "keycastr"
    "meetingbar"
    "monitorcontrol"
    "raycast"
    "rectangle"
    "scroll-reverser"
    # "spotify"
    "vagrant"
    # "virtualbox"
    "yubico-yubikey-personalization-gui"
  ];

  my.home = { config, pkgs, ... }: {
    home.file."Applications/Home Manager Apps".source = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in "${apps}/Applications";

    #home.sessionPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

    programs.git.extraConfig = {
      "includeIf \"gitdir:~/dev/adgear/\"".path = toString (pkgs.writeText "git-includeif-work" ''
        [user]
          email = "${(y: x: "${x}@${y}") "gmail.com" "nic.berbiche"}"
      '');
      "includeIf \"gitdir:~/dotfiles/\"".path = toString (pkgs.writeText "git-includeif-dotfiles" ''
        [user]
          email = "${config.my.identity.email}"
      '');
    };
  };
}
