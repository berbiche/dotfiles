{ config, lib, pkgs, ... }:

# Helpful website: https://r12a.github.io/app-conversion/
# until Waybar supports images (fuck using fonts)
let
  spotify = pkgs.python3Packages.buildPythonApplication {
    name = "spotify.py";
    src = ./spotify.py;
    format = "other";
    doCheck = false;
    dontUnpack = true;
    strictDeps = false;
    buildInputs = [ pkgs.gtk3 pkgs.playerctl ];
    nativeBuildInputs = [ pkgs.gobject-introspection pkgs.wrapGAppsHook ];
    propagatedBuildInputs = [ pkgs.python3Packages.pygobject3 ];
    installPhase = ''
      install -Dm0755 $src $out/bin/spotify
    '';
  };
in
{
  "custom/reboot" = {
    format = "";
    tooltip = false;
    on-click = pkgs.writeShellScript "reboot.sh" ''
      ${pkgs.gnome.zenity}/bin/zenity --question --text "Are you sure you want to reboot?" \
        --title 'Reboot?' \
        --window-icon warning \
        --timeout 10 \
        --height 100 --width 200 &
      pid=$!
      swaymsg "[pid=$pid] floating enable, focus"
      if wait $pid; then
        systemctl reboot
      fi
    '';
  };

  "custom/shutdown" = {
    format = "";
    tooltip = false;
    on-click = pkgs.writeShellScript "shutdown.sh" ''
      ${pkgs.gnome3.zenity}/bin/zenity --question --text "Are you sure you want to shutdown?" \
        --title 'Shutdown?' \
        --window-icon warning \
        --timeout 10 \
        --height 100 --width 200 &
      pid=$!
      swaymsg "[pid=$pid] floating enable, focus"
      if wait $pid; then
        systemctl poweroff
      fi
    '';
  };

  "custom/do-not-disturb" = {
    return-type = "json";
    format = "{icon}";
    format-icons = {
      true = ""; # fontawesome.com/v5/cheatsheet bell f0f3
      false = ""; # fontawesome.com/v5/cheatsheet bell-slash f1f6
    };
    interval = "once";
    exec = pkgs.writeShellScript "do-not-disturb" ''
      status="false"
      if ${pkgs.procps-ng}/bin/pgrep dunst >/dev/null; then
        status="$(${config.services.dunst.package}/bin/dunstctl is-paused)"
      fi
      echo '{"class": "'"$status"'", "alt": "'"$status"'", "tooltip": "Toggle do not disturb"}'
    '';
    exec-on-event = true;
    on-click = pkgs.writeShellScript "do-not-disturb" ''
      ${config.services.dunst.package}/bin/dunstctl set-paused toggle
    '';
  };

  "custom/dark-mode" =  let
    awk = "${pkgs.gawk}/bin/awk";
    gsettings = "${pkgs.glib.bin}/bin/gsettings";
    stdbuf = "${pkgs.coreutils}/bin/stdbuf";
    escape = x: ''"${lib.escape [ ''"'' ] x}"'';
    darkMode = builtins.toJSON {
      text = "Dark";
      alt = "dark";
      tooltip = "Toggle light theme";
      class = "dark";
    };
    lightMode = builtins.toJSON {
      text = "Light";
      alt = "light";
      tooltip = "Toggle dark theme";
      class = "light";
    };
    xdg_data_dir = ''
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"
    '';
  in {
    return-type = "json";
    format = "{icon}";
    format-icons = {
      light = ""; # fontawesome.com/v5/cheatsheet sun f185
      dark = ""; # fontawesome.com/v5/cheatsheet moon f186
    };
    exec = pkgs.writeShellScript "waybar-custom-dark-mode" ''
      ${xdg_data_dir}
      if [[ "$(${gsettings} get org.gnome.desktop.interface gtk-theme)" = "'${config.my.theme.light}'" ]]; then
        echo ${lib.escapeShellArg lightMode}
      else
        echo ${lib.escapeShellArg darkMode}
      fi
      ${gsettings} monitor org.gnome.desktop.interface gtk-theme | \
        ${stdbuf} -o0 ${awk} '{
          if ($2 ~ /'\'''${config.my.theme.light}'\'''/) {
            print ${escape lightMode}
          }
          else {
            print ${escape darkMode}
          }
        }'
        # ${pkgs.jq}/bin/jq --unbuffered --compact-output
    '';
    on-click = pkgs.writeShellScript "waybar-custom-dark-mode-on-click" ''
      ${xdg_data_dir}
      if [[ "$(${gsettings} get org.gnome.desktop.interface gtk-theme)" = "'${config.my.theme.light}'" ]]; then
        ${gsettings} set org.gnome.desktop.interface gtk-theme ${config.my.theme.dark}
      else
        ${gsettings} set org.gnome.desktop.interface gtk-theme ${config.my.theme.light}
      fi
    '';
  };

  "custom/spotify" = rec {
    return-type = "json";
    format = " {}";
    restart-interval = 10;
    exec = "${spotify}/bin/spotify";
    on-click = "${pkgs.sway}/bin/swaymsg -q '[class=Spotify] focus'";
    on-click-right = "${pkgs.playerctl}/bin/playerctl play-pause --player=spotify";
    on-click-middle = on-click-right;
  };

  "custom/weather" = {
    interval = 1800;
    exec = pkgs.writeShellScript "weather.sh" ''
      ${pkgs.curl}/bin/curl -s 'https://wttr.in/?format="%C,+%t'
    '';
  };
}
