{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs core-darwin ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  nix.settings.max-jobs = 8;

  environment.systemPackages = [ pkgs.vagrant pkgs.gnupg ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  #services.emacs.enable = true;

  profiles.dev.wakatime.enable = false;

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.cleanup = "uninstall";
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.brews = [ ];
  homebrew.casks = [
    "docker"
    "kitty"
    "gcenx/wine/unofficial-wineskin"
    "spotify"
    # "vagrant"
    # "virtualbox"
    #"yubico-yubikey-personalization-gui"
  ];

  my.home = { config, pkgs, ... }: {
    home.sessionPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
  };
}
