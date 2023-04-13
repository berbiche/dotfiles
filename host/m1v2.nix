{ config, pkgs, lib, profiles, ... }:

{
  imports = with profiles; [ base dev programs core-darwin ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  nix.settings.max-jobs = 16;

  environment.systemPackages = [ pkgs.vagrant pkgs.gnupg ];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  #services.emacs.enable = true;

  profiles.dev.wakatime.enable = false;

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.brewPrefix = "/opt/homebrew/bin";
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

    "pcp"
  ];
  homebrew.casks = [
    "asix-ax88179"
    "kitty"
    "obs"
    "rancher"
    "spotify"
    "vagrant"
    ### Brew's Virtualbox isn't compatible with aarch64
    #"virtualbox"
    ### Ditto for yubikey-...
    #"yubico-yubikey-personalization-gui"
  ];

  system.defaults.dock = {
    orientation = "bottom";
  };

  my.home = { config, pkgs, osConfig, ... }: {
    home.sessionPath = [ osConfig.homebrew.brewPrefix "/opt/homebrew/sbin" ];
  };
}
