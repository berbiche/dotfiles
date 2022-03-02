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

  # "custom/do-not-disturb" = {
  #   return-type = "json";
  #   format = "{icon}";
  #   format-icons = {
  #     disabled = ""; # fontawesome.com/v5/cheatsheet bell f0f3
  #     enabled  = ""; # fontawesome.com/v5/cheatsheet bell-slash f1f6
  #   };
  #   interval = "once";
  #   exec = pkgs.writeShellScript "do-not-disturb" ''
  #     status="disabled"
  #     if ${pkgs.procps-ng}/bin/pgrep dunst >/dev/null; then
  #       if [ "$(${config.services.dunst.package}/bin/dunstctl is-paused)" = "true" ]; then
  #         status="enabled"
  #       else
  #         status="disabled"
  #       fi
  #     fi
  #     echo '{"class": "'"$status"'", "alt": "'"$status"'", "tooltip": "Toggle do not disturb"}'
  #   '';
  #   exec-on-event = true;
  #   on-click = pkgs.writeShellScript "do-not-disturb" ''
  #     ${config.services.dunst.package}/bin/dunstctl set-paused toggle
  #   '';
  # };

  "custom/do-not-disturb" = let
    swaync-client = "${config.services.sway-notification-center.package}/bin/swaync-client";
  in {
    return-type = "json";
    format = "{icon}";
    format-icons = {
      disabled = ""; # fontawesome.com/v5/cheatsheet bell f0f3
      enabled  = ""; # fontawesome.com/v5/cheatsheet bell-slash f1f6
    };
    interval = "once";
    exec = pkgs.writeShellScript "do-not-disturb" ''
      status="disabled"
      if ${pkgs.procps-ng}/bin/pgrep swaync >/dev/null; then
        if [ "$(${swaync-client} --get-dnd --skip-wait)" = "true" ]; then
          status="enabled"
        else
          status="disabled"
        fi
      fi
      echo '{"class": "'"$status"'", "alt": "'"$status"'", "tooltip": "Toggle do not disturb"}'
    '';
    exec-on-event = true;
    on-click-right = pkgs.writeShellScript "do-not-disturb" ''
      ${swaync-client} --toggle-dnd --skip-wait
    '';
    on-click = pkgs.writeShellScript "open-sway-notification-center" ''
      ${swaync-client} --toggle-panel --skip-wait
    '';
  };

  "custom/dark-mode" =  let
    awk = "${pkgs.gawk}/bin/awk";
    stdbuf = "${pkgs.coreutils}/bin/stdbuf";
    dbus-monitor = "${lib.getBin pkgs.dbus}/bin/dbus-monitor";
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
  in {
    return-type = "json";
    format = "{icon}";
    format-icons = {
      light = ""; # fontawesome.com/v5/cheatsheet sun f185
      dark = ""; # fontawesome.com/v5/cheatsheet moon f186
    };
    exec-on-event = true;
    exec = pkgs.writeShellScript "waybar-custom-dark-mode" ''
      ${dbus-monitor} --session "type='signal',sender='nl.whynothugo.darkman',interface='nl.whynothugo.darkman',path='/nl/whynothugo/darkman',member='ModeChanged'" --monitor |
          ${stdbuf} -o0 ${awk} '
            /member=ModeChanged/ {
              getline;
              if ($2 ~ "light") {
                print ${escape lightMode}
              }
              else {
                print ${escape darkMode}
              }
            }
          '
    '';
    on-click = pkgs.writeShellScript "waybar-custom-dark-mode-on-click" ''
      ${pkgs.darkman}/bin/darkman toggle
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
