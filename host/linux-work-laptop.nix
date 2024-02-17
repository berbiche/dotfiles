{ config, lib, pkgs, ... }:

let
  inherit (config.my) username;
in
{
  my.identity = {
    name = "Nicolas Berbiche";
    email = "nicolas@normie.dev";
    gpgSigningKey = "1D0261F6BCA46C6E";
  };

  # Nix GL issues...
  my.defaults.terminal = "/usr/bin/kitty";
  my.defaults.file-explorer = "${pkgs.cinnamon.nemo}/bin/nemo";

  my.theme.package = pkgs.materia-theme;
  my.theme.dark = "Materia-dark-compact";
  my.theme.light = "Materia-light-compact";

  my.theme.icon.name = "Papirus";
  my.theme.icon.package = pkgs.papirus-icon-theme;

  my.terminal.fontSize = 12.0;
  my.terminal.fontName = "MesloLGS Nerd Font Mono";

  my.theme.cursor.name = "Adwaita";
  my.theme.cursor.size = 24;
  my.theme.cursor.package = pkgs.gnome.gnome-themes-extra;

  my.colors = {
    color0 = "#1d1f21";
    color1 = "#282a2e";
    color2 = "#373b41";
    color3 = "#969896";
    color4 = "#b4b7b4";
    color5 = "#c5c8c6";
    color6 = "#e0e0e0";
    color7 = "#ffffff";
    color8 = "#cc6666";
    color9 = "#de935f";
    color9Darker = "#ba7c50";
    colorA = "#f0c674";
    colorB = "#b5bd68";
    colorC = "#8abeb7";
    colorD = "#81a2be";
    colorE = "#b294bb";
    colorF = "#a3685a";
    color11 = "#5294E2";
    color12 = "#08052B";
  };

  profiles.dev.vscode.enable = false;

  # HomeManager config
  # `man 5 home-configuration.nix`
  manual.manpages.enable = true;

  fonts.fontconfig.enable = lib.mkForce true;

  gtk = {
    enable = true;
    iconTheme = {
      name = config.my.theme.icon.name;
      package = config.my.theme.icon.package;
    };
    theme = {
      name = config.my.theme.light;
      package = config.my.theme.package;
    };
    gtk2.extraConfig = ''
      gtk-cursor-theme-name="${config.my.theme.cursor.name}"
      gtk-cursor-theme-size=${toString config.my.theme.cursor.size}
    '';
    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "${config.my.theme.cursor.name}";
      "gtk-cursor-theme-size" = config.my.theme.cursor.size;
    };
  };
  home.pointerCursor = {
    package = config.my.theme.cursor.package;
    name = "${config.my.theme.cursor.name}";
    size = config.my.theme.cursor.size;
  };
  xsession.preferStatusNotifierItems = true;

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      # name = "Adwaita";
      name = "gtk2";
      package = config.gtk.theme.package;
      # package = pkgs.adwaita-qt;
    };
  };

  xdg.userDirs = {
    enable = true;
    extraConfig = {
      "XDG_SCREENSHOTS_DIR" = "${config.xdg.userDirs.pictures}/screenshots";
    };
  };

  # Passwords and stuff
  # Disabled: https://github.com/nix-community/home-manager/issues/1454
  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [ "secrets" ];
}
