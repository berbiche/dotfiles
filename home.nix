{ config, lib, pkgs, ... }:

let
  base-dir = ./. + "/home-manager";
  overlays-dir = base-dir + "/overlays";
  overlays =
    let
      overlays = lib.mapAttrs (n: _: import (overlays-dir + "/${n}")) (builtins.readDir overlays-dir);
    in lib.attrValues overlays;
in
{
  home.stateVersion = "20.09";

  imports = map (x: base-dir + "/${x}") [
    # ./config.nix
    "systemd.nix"
    "k8s.nix"
    "gpg.nix"
    "programs.nix"
  ];

  nixpkgs.config = import ./config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;
  nixpkgs.overlays = overlays;
  xdg.configFile."nixpkgs/overlays".source = overlays-dir;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
    # Fix Firefox. See <https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/>
    MOZ_DBUS_REMOTE = 1;
  };

  # HomeManager config
  manual.manpages.enable = true;
  news.display = "silent";

  # XDG
  fonts.fontconfig.enable = true;
  xdg.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.gnome3.gnome_themes_standard;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  services.lorri.enable = true;
  services.blueman-applet.enable = true;
  services.gnome-keyring.enable = true;
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;
  #services.network-manager-applet.enable = true;

  # Run emacs as a service
  services.emacs.enable = true;
  programs.emacs.enable = true;

  # Copy the scripts folder
  home.file."scripts" = {
    source = toString base-dir + "/scripts";
    recursive = false; # we want the folder symlinked, not its files
  };
}
