{ config, lib, pkgs, ... }:

{
  home.stateVersion = "20.09";

  imports = [
    ./systemd.nix
    ./gpg.nix
    ./programs.nix
  ];

  xdg.configFile."nixpkgs/config.nix".source = ./config.nix;
  xdg.configFile."nixpkgs/overlays".source = ../overlays;
  xdg.configFile."nixpkgs/nix".source = ../nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # programs.home-manager.path = "$HOME/dev/github.com/home-manager";
  # programs.home-manager.path = <home-manager>;

  home.sessionVariables = {
    NIX_PAGER = "less --RAW-CONTROL-CHARS --quit-if-one-screen";
  };

  # HomeManager config
  # `man 5 home-configuration.nix`
  manual.manpages.enable = true;

  # XDG
  fonts.fontconfig.enable = lib.mkForce true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Adwaita";
      # Covered by the theme package below
      # package = pkgs.gnome3.gnome-themes-extra;
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
    source = ./scripts;
    recursive = false; # we want the folder symlinked, not its files
  };
}

