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

  nix.settings.max-jobs = 6;

  environment.systemPackages = [ pkgs.vagrant pkgs.gnupg ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  #services.emacs.enable = true;

  profiles.dev.wakatime.enable = false;

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.brewPrefix = "/usr/local/Homebrew/bin";
  homebrew.brews = [
    # Yeah, I know...
    "autoconf" "automake" "libtool"
    "libidn" "pkg-config"
    "msgpack" "tinycdb"
    "libmaxminddb" "openssl@1.1" "libxslt" "fop"
    "kerl"
  ];
  homebrew.casks = [
    "obs"
    "rancher"
    "vagrant"
    "virtualbox"
    "yubico-yubikey-personalization-gui"
  ];

  system.defaults.dock = {
    orientation = "bottom";
  };
}
