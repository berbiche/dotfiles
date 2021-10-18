{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs core-darwin ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nix.maxJobs = 6;

  environment.systemPackages = [ pkgs.vagrant pkgs.gnupg ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  #services.emacs.enable = true;

  profiles.dev.wakatime.enable = false;

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.brewPrefix = "/usr/local/Homebrew/bin";
  homebrew.brews = [ ];
  homebrew.casks = [
    "vagrant"
    "yubico-yubikey-personalization-gui"
  ];
}
