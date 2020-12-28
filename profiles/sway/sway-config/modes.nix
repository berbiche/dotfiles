{ config, pkgs, lib, binaries }:

let
  inherit (config.lib.my) getScript;
  inherit (config.wayland.windowManager.sway.config)
    modifier
    left
    right
    up
    down;
in
lib.mkOptionDefault {
  resize = {
    "${left}"  = "resize shrink width 10 px";
    "${down}"  = "resize grow height 10 px";
    "${up}"    = "resize shrink height 10 px";
    "${right}" = "resize grow width 10 px";
    Left  = "resize shrink width 10 px";
    Down  = "resize grow height 10 px";
    Up    = "resize shrink height 10 px";
    Right = "resize grow width 10 px";

    Escape = "mode default";
    Return = "mode default";
  };

  gaps = {
    "1" = ''
      mode default; \
        gaps inner current set 0;\
        gaps outer current set 0;
    '';
    "2" = ''
      mode default; \
        gaps inner current set 10; \
        gaps outer current set 0;
    '';
    Plus       = "gaps inner current plus 5";
    Underscore = "gaps inner current minus 5";
    Equal      = "gaps outer current plus 5";
    Minus      = "gaps outer current minus 5";

    "${left}"  = "gaps left  current plus 5";
    "${right}" = "gaps right current plus 5";
    "${down}"  = "gaps down  current plus 5";
    "${up}"    = "gaps up    current plus 5";

    "Shift+${left}"  = "gaps left  current minus 5";
    "Shift+${right}" = "gaps right current minus 5";
    "Shift+${down}"  = "gaps down  current minus 5";
    "Shift+${up}"    = "gaps up    current minus 5";

    Return = "mode default";
    Escape = "mode default";
  };

  multimedia = rec {
    Left  = "exec ${binaries.playerctl} previous";
    Right = "exec ${binaries.playerctl} next";
    Up    = "exec ${binaries.playerctl} play-pause";

    n   = "exec ${getScript "volume.sh"} 'mic-mute";
    m   = "exec ${getScript "volume.sh"} 'toggle-mute'";
    Period = "exec ${getScript "volume.sh"} 'decrease'";
    Comma = "exec ${getScript "volume.sh"} 'increase'";

    Return = "mode default";
    Escape = "mode default";
  };

  execute-focus = {
    # Spotify
    s = ''[class="Spotify"] focus; mode default'';

    r = "noop";
    # Riot
    "r+i" = ''[class="Riot"] focus; mode default'';
    # RocketChat
    "r+c" = ''[class="Rocket.Chat" instance="rocket.chat"] focus; mode default'';
    # Lollypop (Gnome music player)
    l = ''[app_id="lollypop"] focus; mode default'';
    # Bitwarden
    b = ''[class="Bitwarden" instance="bitwarden"] focus; mode default'';
    # Discord
    d = ''[class="discord"] focus; mode default'';
    # Emacs
    e = ''[class="Emacs"] focus; mode default'';
    # Pavucontrol
    c = "exec ${binaries.audiocontrol}; mode default";

    Return = "mode default";
    Escape = "mode default";
  };
}
