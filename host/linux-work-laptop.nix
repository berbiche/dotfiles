## Ubuntu laptop
{ inputs, config, lib, pkgs, ... }:

{
  my.identity = {
    name = "Nicolas Berbiche";
    email = "nicolas@normie.dev";
    gpgSigningKey = "1D0261F6BCA46C6E";
  };

  # Nix GL issues...
  my.defaults.terminal = "/usr/bin/kitty";
  my.defaults.file-explorer = "";

  my.theme.light = "Orchis";
  my.theme.dark = "Orchis-dark";
  my.theme.package = pkgs.orchis-theme;

  my.theme.icon.name = "Papirus";
  my.theme.icon.package = pkgs.papirus-icon-theme;

  my.terminal.fontSize = 12.0;
  my.terminal.fontName = "MesloLGS Nerd Font Mono";

  # my.theme.cursor.name = "Adwaita";
  # my.theme.cursor.size = 24;
  # my.theme.cursor.package = pkgs.gnome.gnome-themes-extra;

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
  profiles.dev.asdf.enable = true;

  # HomeManager config
  # `man 5 home-configuration.nix`
  manual.manpages.enable = true;

  fonts.fontconfig.enable = lib.mkForce true;

  home.keyboard = {
    layout = "us";
    options = ["compose:ralt" "caps:escape"];
  };
  dconf.settings."org/gnome/desktop/input-sources" = {
    xkb-options = ["compose:ralt" "caps:escape"];
  };

  gtk.enable = true;
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

  home.packages = with pkgs; [
    wl-clipboard # wl-copy/wl-paste
  ];

  # Passwords and stuff
  # Disabled: https://github.com/nix-community/home-manager/issues/1454
  services.gnome-keyring.enable = true;
  services.gnome-keyring.components = [ "secrets" ];

  services.darkman = let
    dconf = "${lib.getBin pkgs.dconf}/bin/dconf";
  in {
    enable = true;
    settings.usegeoclue = true;
    darkModeScripts.gtk-theme = ''
      ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    '';
    lightModeScripts.gtk-theme = ''
      ${dconf} write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    '';
  };

  # Can't change default shell, so `exec` fish from bashrc login shell
  programs.bash.bashrcExtra = ''
    if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION='''
      exec fish $LOGIN_OPTION
    fi
  '';

  # Override the service and disable it
  # echo 'X-GNOME-Autostart-enabled=false' | sudo tee -a /etc/xdg/autostart/gnome-keyring-ssh.desktop
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = lib.mkIf false ''
    [Desktop Entry]
    Name=SSH Key Agent
    #Hidden=true
    X-GNOME-Autostart-enabled=false
  '';
}
