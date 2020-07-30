{ config, lib, pkgs, ... }:

{
  imports = [
    ./systemd.nix
    ./gpg.nix
    ./programs.nix
  ];

  options.my.identity = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Fullname";
    };
    email = lib.mkOption {
      type = lib.types.str;
      description = "Email";
    };
  };

  config = {
    home.stateVersion = "20.09";

    my.identity.name = "Nicolas Berbiche";
    my.identity.email = "nic.berbiche@gmail.com";

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

    # Passwords and stuff
    services.gnome-keyring.enable = true;

    services.lorri.enable = true;
    services.blueman-applet.enable = true;
    services.kdeconnect.enable = true;
    services.kdeconnect.indicator = true;
    # The service file does not start the applet with libindicator
    # So we use our own in systemd-services/nm-applet
    #services.network-manager-applet.enable = true;

    # Run emacs as a service
    services.emacs.enable = true;
    programs.emacs.enable = true;

    # Copy the scripts folder
    home.file."scripts" = {
      source = ./scripts;
      recursive = false; # we want the folder symlinked, not its files
    };
  };
}