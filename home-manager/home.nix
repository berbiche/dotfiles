{ config, lib, pkgs, ... }:

let
  overlays =
    let
      o = lib.mapAttrs (n: _: import (toString ./. + "/overlays/${n}")) (builtins.readDir ./overlays);
    in lib.attrValues o;
in
{
  home.stateVersion = "20.09";

  imports = [
    # ./config.nix
    ./systemd.nix
    ./k8s.nix
    ./gpg.nix
    ./programs.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u"
  ];
  nixpkgs.overlays = overlays;

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
    source = ./scripts;
    recursive = false; # we want the folder symlinked, not its files
  };
}
