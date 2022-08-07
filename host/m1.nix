{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs core-darwin ];

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
    "kitty"
    "gcenx/wine/unofficial-wineskin"
    "spotify"
    "rancher"
    # "vagrant"
    # "virtualbox"
    #"yubico-yubikey-personalization-gui"
  ];

  my.home = { config, pkgs, osConfig, ... }: {
    home.sessionPath = [ osConfig.homebrew.brewPrefix "/opt/homebrew/sbin" ];
  };
}
