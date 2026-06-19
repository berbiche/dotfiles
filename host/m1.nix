{ config, pkgs, lib, profiles, ... }:

let availableOnDarwin = lib.meta.availableOn pkgs.stdenv.hostPlatform;
in {
  imports = with profiles; [ base dev programs core-darwin ];

  my.location = {
    latitude = 45.508;
    longitude = -73.597;
  };

  profiles.dev.vmware.enable = false;

  # nix.settings.max-jobs = 16;
  determinateNix.customSettings.max-jobs = 16;

  environment.systemPackages = [ pkgs.gnupg ];

  system.defaults.loginwindow.LoginwindowText = "Property of Nicolas Berbiche";

  # nix.distributedBuilds = true;
  # nix.settings.trusted-substituters = [ "ssh-ng://nixos-builder.node.tq.rs" ];
  # nix.settings.trusted-public-keys =
  #   [ "nixos-builder.node.tq.rs:iRHmjI5sQ7vkwkArTZIBIYm8dFVs9VzVbgNwNhlzBfc=" ];
  # nix.buildMachines = [{
  #   systems = [ "x86_64-linux" "i686-linux" ];
  #   supportedFeatures = [ "kvm" "big-parallel" ];
  #   maxJobs = 14;
  #   protocol = "ssh-ng";
  #   sshUser = "nicolas";
  #   hostName = "nixos-builder.node.tq.rs";
  #   sshKey = "/etc/nix/nixos-builder.key";
  #   publicHostKey =
  #     "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1RUHlybWxObExmcnVSMnJONXB2MEJSeGtqVGJna2wyb1E5dm5YSjNYOEMgcm9vdEBuaXhvcy1idWlsZGVyCg==";
  #   }
  #   {
  #     systems = [ "x86_64-linux" "i686-linux" ];
  #     supportedFeatures = [ "big-parallel" ];
  #     sshUser = "root";
  #     maxJobs = 8;
  #     hostName = "172.16.2.6";
  #     sshKey = "/Users/nberbiche/.ssh/otakuthon";
  #     # publicHostKey = "H+DeIUeuXgqoDI+XcNL43mBheZGSIBRHrPz/mrIIQqw";
  #   }
  # ];
  # Instruct remote builders to use their own substitute cache
  # nix.settings.builders-use-substitutes = true;

  homebrew.enable = true;
  homebrew.onActivation.upgrade = true;
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.prefix = "/opt/homebrew";
  homebrew.taps = [ ];
  homebrew.brews = [
    "bitwarden-cli"

    "colima"
    "docker"
    "docker-compose"
    "docker-credential-helper"
  ];
  homebrew.casks = [
    "android-platform-tools"
    # "asix-ax88179"
    "cmux"
    "ghostty"

    "openchamber"

    "spotify"
    "switchresx"

    # Wallpaper tool
    "wallspace"
  ];

  my.home = { config, pkgs, osConfig, ... }: {
    home.sessionPath = [
      "${osConfig.homebrew.prefix}/bin"
      "${osConfig.homebrew.prefix}/sbin"
    ];
    home.packages = [
      pkgs.anki-bin
      # Not building with determinate nix (2026-05-08)
      # pkgs.coconutbattery
      pkgs.awscli2
    ];
  };
}
