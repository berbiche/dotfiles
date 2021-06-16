{ lib, pkgs, ... }:

let
  # Stolen from Tristan's config
  theme = {
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
    colorA = "#f0c674";
    colorB = "#b5bd68";
    colorC = "#8abeb7";
    colorD = "#81a2be";
    colorE = "#b294bb";
    colorF = "#a3685a";
  };

  transparency = lvl: color:
    assert lvl <= 100 && lvl >= 0;
    color + lib.toHexString (lvl * 256 / 100);

  partial-transparency = transparency 90;
in
{
  my.home = {
    systemd.user.services.dunst.Service.UnsetEnvironment = [ "DISPLAY" ];

    services.dunst.enable = true;
    # https://github.com/dunst-project/dunst/pull/855
    services.dunst.package = pkgs.nixpkgs-wayland.dunst.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "dunst-project";
        repo = "dunst";
        rev = "3e1b3064c1600f1feb928f32b462a2e27a0fbc70";
        hash = "sha256-N7GrjA7qT1D5Fas4W6tE3hPI1hFVhSHtJw9Pxb/7a1k=";
      };
    });
    services.dunst.iconTheme = {
      # name = "Papirus-Dark";
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size = "64x64";
    };
    services.dunst.settings = {
      global = {
        font = "Sans 10";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        follow = "keyboard";

        # Wayland option
        layer = "top";

        alignment = "top";
        icon_position = "left";
        # vertical_alignment = "top";
        origin = "top-center";
        height = "(70, 250)";
        width = "350";
        offset = "0x10";
        min_icon_size = 64/*px*/;
        max_icon_size = 64/*px*/;
        notification_limit = 4;

        line_height = 3;
        separator_height = 10/*px*/;
        padding = 6/*px*/;
        horizontal_padding = 6/*px*/;

        ellipsize = "end";
        hide_duplicate_count = true;
        history_length = 15;
        idle_threshold = 0;
        ignore_newline = false;
        indicate_hidden = false;
        show_age_threshold = -1;
        show_indicators = false;
        shrink = false;
        sort = false;
        stack_duplicates = true;
        sticky_history = false;
        word_wrap = true;

        dmenu = "${pkgs.wofi}/bin/wofi -p dunst -dmenu";
        browser = "${pkgs.firefox}/bin/firefox --new-tab";

        corner_radius = 4;
        frame_color = theme.color8;
        frame_width = 2;
        separator_color = "frame";
      };
      urgency_low = {
        background = partial-transparency theme.color1;
        foreground = theme.color4;
        frame_color = theme.color8;
        timeout = 10;
      };
      urgency_normal = {
        background = partial-transparency theme.color1;
        foreground = theme.color4;
        frame_color = theme.color8;
        timeout = 10;
      };
      urgency_critical = {
        background = partial-transparency theme.color1;
        foreground = theme.color4;
        frame_color = theme.color8;
        timeout = 10;
      };
    };
  };
}
