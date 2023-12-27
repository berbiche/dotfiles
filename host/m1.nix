{ config, pkgs, lib, profiles, ... }:

let
  availableOnDarwin = lib.meta.availableOn pkgs.stdenv.hostPlatform;
in
{
  imports = with profiles; [ base dev programs core-darwin ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  profiles.dev.vmware.enable = true;

  nix.settings.max-jobs = 16;

  environment.systemPackages = [ pkgs.gnupg ];

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "kvm" "big-parallel" ];
      maxJobs = 14;
      protocol = "ssh-ng";
      sshUser = "nicolas";
      hostName = "nixos-builder.node.tq.rs";
      sshKey = "/etc/nix/nixos-builder.key";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1RUHlybWxObExmcnVSMnJONXB2MEJSeGtqVGJna2wyb1E5dm5YSjNYOEMgcm9vdEBuaXhvcy1idWlsZGVyCg==";
    }
    {
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "big-parallel" ];
      sshUser = "root";
      maxJobs = 8;
      hostName = "172.16.2.6";
      sshKey = "/Users/nberbiche/.ssh/otakuthon";
      # publicHostKey = "H+DeIUeuXgqoDI+XcNL43mBheZGSIBRHrPz/mrIIQqw";
    }
  ];
  # nix.settings.builders-use-substitutes = true;

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.taps = [
    "homebrew/cask-versions"
  ];
  homebrew.brews = [
    "bitwarden-cli"
  ];
  homebrew.casks = [
    "asix-ax88179"
    "kitty"
    # "gcenx/wine/unofficial-wineskin"
    "spotify"
    "rancher"
    "switchresx"
    "vagrant"

    "burp-suite"

    # Available on cask-versions tap
    "virtualbox-beta"
  ];

  my.home = { config, pkgs, osConfig, ... }: {
    home.sessionPath = [ osConfig.homebrew.brewPrefix "/opt/homebrew/sbin" ];
    home.packages = [
      pkgs.anki-bin
    ];
  };
}
