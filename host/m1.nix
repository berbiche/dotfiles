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

  nix.distributedBuilds = true;
  nix.buildMachines = [{
    systems = [ "x86_64-linux" ];
    supportedFeatures = [ "kvm" "big-parallel" ];
    maxJobs = 14;
    protocol = "ssh-ng";
    sshUser = "nicolas";
    hostName = "nixos-builder.node.tq.rs";
    sshKey = "/Users/${config.my.username}/.ssh/builder";
    # publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1RUHlybWxObExmcnVSMnJONXB2MEJSeGtqVGJna2wyb1E5dm5YSjNYOEMgcm9vdEBuaXhvcy1idWlsZGVyCg==";
  }];
  # nix.settings.builders-use-substitutes = true;

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "uninstall";
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
