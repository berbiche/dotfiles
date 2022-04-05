{ config, lib, pkgs, ... }:

let
  inherit (config.profiles.i3) binaries;
  inherit (config.xsession.windowManager.i3.config) left up right down;
  mod = config.xsession.windowManager.i3.config.modifier;
  ws = config.profiles.i3-sway.workspaces;

  # Wrapper around `exec` to always use a login shell (and inherit environment variables)
  exec = n: "exec ${lib.escapeShellArg pkgs.bash}/bin/bash -lc "
    + lib.escapeShellArg (toString n);

  withPlayerctld = lib.optionalString config.services.playerctld.enable "-p playerctld";
in
{
  xsession.windowManager.i3.config.keybindings = {
    "${mod}+Shift+q" = "exec ${binaries.logout}";
    "${mod}+Shift+d" = "kill";
    "${mod}+d" = exec "${binaries.launcher}";

    "${mod}+BackSpace"      = "exec ${binaries.locker}";
    "${mod}+Ctrl+BackSpace" = "exec ${binaries.logout}";

    "${mod}+Shift+Return" = exec "${binaries.floating-term}";
    "${mod}+p" = exec "${binaries.menu}";

    "${mod}+semicolon" = exec "${binaries.emacsclient}";

    "${mod}+z"       = "focus child";
    "${mod}+Shift+Z" = "focus parent";
    "${mod}+Shift+minus" = "move to scratchpad";
    "${mod}+minus"       = "scratchpad show";
    "${mod}+Shift+Space" = "floating toggle, border normal";

    "${mod}+f"       = "fullscreen toggle";
    "${mod}+Shift+f" = "fullscreen toggle global";
    "${mod}+c"       = "border toggle";

    "${mod}+h" = "focus left";
    "${mod}+j" = "focus down";
    "${mod}+k" = "focus up";
    "${mod}+l" = "focus right";
    "${mod}+Shift+h" = "move left";
    "${mod}+Shift+j" = "move down";
    "${mod}+Shift+k" = "move up";
    "${mod}+Shift+l" = "move right";

    "${mod}+i" = "workspace prev_on_output";
    "${mod}+o" = "workspace next_on_output";
    "${mod}+Shift+i" = "focus output left";
    "${mod}+Shift+o" = "focus output right";

    "${mod}+v" = "split h";
    "${mod}+b" = "split v";
    "${mod}+e" = "split toggle";
    "${mod}+s" = "layout stacking";
    "${mod}+w" = "layout tabbed";
    "${mod}+Shift+s" = "sticky toggle";

    "XF86AudioPause" = (exec "${binaries.playerctl} ${withPlayerctld} pause");
    "XF86AudioPlay"  = (exec "${binaries.playerctl} ${withPlayerctld} play");
    "XF86AudioPrev"  = (exec "${binaries.playerctl} previous");
    "Pause"          = (exec "${binaries.playerctl} ${withPlayerctld} play-pause");

    # Volume stuff
    "XF86AudioRaiseVolume" = (exec "${binaries.volume} 'increase'");
    "XF86AudioLowerVolume" = (exec "${binaries.volume} 'decrease'");
    "XF86AudioMute"        = (exec "${binaries.volume} 'toggle-mute'");
    "XF86AudioMicMute"     = (exec "${binaries.volume} 'mic-mute'");
    "${mod}+Backslash"     = (exec "${binaries.volume} 'mic-mute'");
    "Scroll_Lock"          = (exec "${binaries.volume} 'mic-mute'");

    "--release Print"       = (exec "${binaries.screenshot} 'selection'");
    "--release Alt+Print"   = (exec "${binaries.screenshot} 'window'");
    "--release Shift+Print" = (exec "${binaries.screenshot} 'screen'");
    "--release Ctrl+Print"  = (exec "${binaries.screenshot} 'everything'");

    # Paste a specific clipboard item
    "Shift+Insert" = "exec ${binaries.xfce4-popup-clipman}";

    # Browser
    "${mod}+n"       = (exec binaries.browser);
    "${mod}+Shift+n" = (exec binaries.browser-private);
    "${mod}+Ctrl+n"  = (exec binaries.browser-work-profile);

    "${mod}+1" = "workspace ${ws.WS1}";
    "${mod}+2" = "workspace ${ws.WS2}";
    "${mod}+3" = "workspace ${ws.WS3}";
    "${mod}+4" = "workspace ${ws.WS4}";
    "${mod}+5" = "workspace ${ws.WS5}";
    "${mod}+6" = "workspace ${ws.WS6}";
    "${mod}+7" = "workspace ${ws.WS7}";
    "${mod}+8" = "workspace ${ws.WS8}";
    "${mod}+9" = "workspace ${ws.WS9}";
    "${mod}+0" = "workspace ${ws.WS10}";
    # Move container
    "${mod}+Shift+1" = "move container to workspace ${ws.WS1}";
    "${mod}+Shift+2" = "move container to workspace ${ws.WS2}";
    "${mod}+Shift+3" = "move container to workspace ${ws.WS3}";
    "${mod}+Shift+4" = "move container to workspace ${ws.WS4}";
    "${mod}+Shift+5" = "move container to workspace ${ws.WS5}";
    "${mod}+Shift+6" = "move container to workspace ${ws.WS6}";
    "${mod}+Shift+7" = "move container to workspace ${ws.WS7}";
    "${mod}+Shift+8" = "move container to workspace ${ws.WS8}";
    "${mod}+Shift+9" = "move container to workspace ${ws.WS9}";
    "${mod}+Shift+0" = "move container to workspace ${ws.WS10}";
    # Move container and focus
    "${mod}+Ctrl+1" = "move container to workspace ${ws.WS1};  workspace ${ws.WS1}";
    "${mod}+Ctrl+2" = "move container to workspace ${ws.WS2};  workspace ${ws.WS2}";
    "${mod}+Ctrl+3" = "move container to workspace ${ws.WS3};  workspace ${ws.WS3}";
    "${mod}+Ctrl+4" = "move container to workspace ${ws.WS4};  workspace ${ws.WS4}";
    "${mod}+Ctrl+5" = "move container to workspace ${ws.WS5};  workspace ${ws.WS5}";
    "${mod}+Ctrl+6" = "move container to workspace ${ws.WS6};  workspace ${ws.WS6}";
    "${mod}+Ctrl+7" = "move container to workspace ${ws.WS7};  workspace ${ws.WS7}";
    "${mod}+Ctrl+8" = "move container to workspace ${ws.WS8};  workspace ${ws.WS8}";
    "${mod}+Ctrl+9" = "move container to workspace ${ws.WS9};  workspace ${ws.WS9}";
    "${mod}+Ctrl+0" = "move container to workspace ${ws.WS10}; workspace ${ws.WS10}";
  };
}
