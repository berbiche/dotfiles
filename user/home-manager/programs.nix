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
    libnotify                    # `notify-send` notifications to test mako
    hexyl

    #
    dex # execute .desktop files
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

  # ctrl-t, ctrl-r, kill <tab><tab>
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Program prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    # options = [ "--no-aliases" ];
  };

  programs.swaylock = {
    enable = true;
    imageFolder = config.xdg.userDirs.pictures + "/wallpaper";
  };
}
