{ config, lib, pkgs, ... }:

let
  base-dir = ./. + "/home-manager";
  base-imports = map (x: base-dir + "/${x}") [
    "systemd.nix"
    "gpg.nix"
    "programs.nix"
  ];
in
{
  home.stateVersion = "20.09";
  # home.username = config.username;
  # home.homeDirectory = "/home/${config.username}";

  imports = base-imports ++ [ ../overlays.nix ];

  nixpkgs.config = import ./config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;
  xdg.configFile."nixpkgs/overlays".source = ../overlays;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # programs.home-manager.path = "$HOME/dev/github.com/home-manager";

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
    # Fix Firefox. See <https://mastransky.wordpress.com/2020/03/16/wayland-x11-how-to-run-firefox-in-mixed-environment/>
    MOZ_DBUS_REMOTE = 1;
  };

  # HomeManager config
  manual.manpages.enable = true;
  news.display = "silent";

  # XDG
  fonts.fontconfig.enable = lib.mkForce true;
  xdg.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Adwaita";
      package = pkgs.gnome3.gnome-themes-extra;
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
    source = toString (base-dir + "/scripts");
    recursive = false; # we want the folder symlinked, not its files
  };
}
