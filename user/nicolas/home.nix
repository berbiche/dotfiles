{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) mkIf mkDefault;
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  my.identity = {
    name = "Nicolas Berbiche";
    email = "nicolas@normie.dev";
    gpgSigningKey = "1D0261F6BCA46C6E";
  };

  my.defaults.terminal = "${config.programs.alacritty.package}/bin/alacritty";
  # my.defaults.terminal = "${config.programs.kitty.package}/bin/kitty";
  my.defaults.file-explorer = mkIf isLinux "${pkgs.cinnamon.nemo}/bin/nemo";

  # pkgs.numix-gtk-theme
  # pkgs.yaru-theme
  # my.theme.package = pkgs.arc-theme;
  # my.theme.light = "Arc";
  # my.theme.dark = "Arc-Dark";
  # my.theme.package = pkgs.materia-theme;
  # my.theme.light = "Materia-light-compact";
  # my.theme.dark = "Materia-dark-compact";
  # my.theme.package = pkgs.adw-gtk3-theme;
  # my.theme.light = "adw-gtk";
  # my.theme.dark = "adw-gtk3-dark";
  my.theme.package = pkgs.orchis-theme;
  my.theme.light = "Orchis";
  my.theme.dark = "Orchis-dark";

  my.theme.cursor.name = "Adwaita";
  my.theme.cursor.size = 24;
  my.theme.cursor.package = pkgs.gnome.gnome-themes-extra;

  my.theme.icon.name = "Papirus";
  my.theme.icon.package = pkgs.papirus-icon-theme;
  # my.theme.icon.name = "Adwaita";
  # my.theme.icon.package = pkgs.gnome.adwaita-icon-theme;

  my.terminal.fontSize = 12.0;
  my.terminal.fontName = lib.mkMerge [
    (mkIf isDarwin "Menlo")
    (mkIf (!isDarwin) "MesloLGS Nerd Font Mono")
  ];

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

  # HomeManager config
  # `man 5 home-configuration.nix`
  manual.manpages.enable = true;

  fonts.fontconfig.enable = lib.mkForce true;

  gtk = {
    enable = mkDefault isLinux;
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
  xsession.pointerCursor = {
    package = config.my.theme.cursor.package;
    name = "${config.my.theme.cursor.name}";
    size = config.my.theme.cursor.size;
  };
  xsession.preferStatusNotifierItems = mkDefault isLinux;

  qt = {
    enable = mkDefault isLinux;
    platformTheme = "gtk";
    style = {
      # name = "Adwaita";
      name = "gtk2";
      package = config.gtk.theme.package;
      # package = pkgs.adwaita-qt;
    };
  };


  xdg.userDirs = {
    enable = mkDefault isLinux;
    extraConfig = {
      "XDG_SCREENSHOTS_DIR" = "${config.xdg.userDirs.pictures}/screenshots";
    };
  };

  # Passwords and stuff
  services.gnome-keyring.enable = mkDefault isLinux;
  # I use gpg-agent for ssh and gpg, so only use it for secrets
  services.gnome-keyring.components = [ "secrets" ];

  # Make sure to open the right port range
  services.kdeconnect.enable = mkDefault isLinux;
  services.kdeconnect.indicator = mkDefault isLinux;

  services.blueman-applet.enable = mkDefault isLinux;
  # Started with libindicator if `xsession.preferStatusNotifierItems = true`
  services.network-manager-applet.enable = mkDefault isLinux;

  services.plex-mpv-shim.enable = mkDefault isLinux;

  # Playerctl smart daemon to stop the "last player"
  # supposedly smarter than the default play-pause behavior
  # Disabled (2021-08-09) because it's not possible to ignore certain players (e.g. Firefox)
  services.playerctld.enable = false;

  home.packages = mkIf isLinux [
    pkgs.thunderbird

    # pkgs.pantheon.elementary-files
    # pkgs.pantheon.elementary-icon-theme
    pkgs.pantheon.elementary-music

    # Music player
    pkgs.tauon

    # Temporary
    pkgs.zoom-us
    pkgs.discord
    pkgs.discord-canary
    pkgs.teams

    # From my overlays
    pkgs.cheminot-ets
  ];

  # Copy the scripts folder
  home.file."scripts".source = let
    path = lib.makeBinPath (with pkgs; [
      gawk gnused jq wget bc
      pulseaudio # for pactl
      pamixer # volume control
      avizo # show a popup notification for the volume level
      sway # for swaymsg
      flameshot
      wl-clipboard # wl-copy/wl-paste
      fzf # menu
      wofi # menu
      xdg-user-dirs # for the screenshot tool
      networkmanager # for nmcli
      notify-send_sh # from my overlays
      playerctl # to control mpris players
      util-linux # flock
    ]);
  in mkIf isLinux "${
    # For the patchShebang phase
    pkgs.runCommandLocal "sway-scripts" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir -p "$out"/bin
      cp --no-preserve=mode -T -r "${../scripts}" "$out"/_bin
      chmod +x "$out"/_bin/*
      for i in "$out"/_bin/*; do
        makeWrapper "$i" "$out"/bin/"$(basename $i)" --prefix PATH : ${path}
      done
    ''
  }/bin";

  lib.my = mkIf isLinux {
    # Instead of using the path in the nix store, return the relative path of the script in my configuration
    # This makes it possible to update scripts without reloading my Sway configuration
    getScript = name:
      assert lib.assertMsg (builtins.pathExists (../scripts + "/${name}"))
        "The specified script '${name}' does not exist in the 'scripts/' folder";
      "${config.home.homeDirectory}/${config.home.file."scripts".target}/${name}";
  };
}
