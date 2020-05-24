{ config, lib, pkgs, ... }:

let
  inherit (builtins) map attrNames readDir import;
  # Import all programs under ./programs using their default.nix
  customPrograms = map (p: ./. + "/programs/${p}") (attrNames (readDir ./programs));
  #customPrograms = map (name: import (./. + "/programs/${name}") { config lib pkgs }) programs;
in
{
  imports = customPrograms;

  home.packages = with pkgs; [
    pavucontrol

    bitwarden bitwarden-cli
    jq                           # cli to extract data out of json input
    #kanshi                      # sway output management
    libnotify

    #
    dex # execute .desktop files
    gnome3.gnome_themes_standard
    gnome3.nautilus
    gnome3.networkmanager-openconnect
    gnome3.rhythmbox
    riot-desktop
    spotify
    pamixer # control pulse audio volume in scripts
    discord # unfortunately

    # Virtualization software
    gnome3.gnome-boxes
    virt-manager

    # For those rare times
    chromium

    # Essentials
    vscode
    jetbrains.idea-community

    # Entertainment
    youtube-dl

    # Programming
    #llvmPackages.bintools
    clang
    python3
    gnumake
    powershell
    direnv
    niv

    # TUIs
    tig            # GIT
    ncdu           # File usage


    # Programming tools
    ###################
    # Postman alternative
    insomnia
  ];

  # Preview directory content and find directory to `cd` to
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  # Advanced less
  programs.lesspipe.enable = false;

  # Program prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
