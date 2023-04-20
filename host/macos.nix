{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs core-darwin ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  nix.settings.max-jobs = 6;

  environment.systemPackages = [ pkgs.vagrant pkgs.gnupg ];

  #services.emacs.enable = true;

  profiles.dev.wakatime.enable = false;

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.brewPrefix = "/usr/local/Homebrew/bin";
  homebrew.taps = [
    "homebrew/cask-drivers"
  ];
  homebrew.brews = [
    # Yeah, I know...
    "autoconf" "automake" "libtool"
    "libidn" "pkg-config"
    "msgpack" "tinycdb"
    "libmaxminddb" "openssl@1.1" "libxslt" "fop"
    "kerl"
  ];
  homebrew.casks = [
    "asix-ax88179"
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
