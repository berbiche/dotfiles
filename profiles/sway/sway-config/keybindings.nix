{ config, options, pkgs, lib, binaries, rootPath, workspaces }:

let
  inherit (config.wayland.windowManager.sway.config)
    modifier
    left
    right
    up
    down;

  # This is a terrible idea, but I know what I'm doing
  # I want to reuse the default keybindings while overriding the default flags
  # passed to Sway's `bindsym`. See `makeNoRepeat`.
  defaultKeybindings = let
    # these variable names have no meanings
    md = lib.head options.wayland.windowManager.sway.config.type.functor.wrapped.functor.payload.modules; 
    kb = (lib.head md.imports).options.keybindings.default;
  in assert builtins.isAttrs kb; kb;

  inherit (config.lib.my) getScript;

  ws = lib.mapAttrs (_: lib.escapeShellArg) workspaces;

  OUTPUT-LAPTOP = "eDP-1";

  # Sway's poor default to repeat the action continuously is dumb
  makeNoRepeat = lib.mapAttrs' (n: v:
    let default = "--no-warn ${n}"; in
    lib.nameValuePair
      (if v ? repeat then default else "--no-repeat ${default}")
      (v.repeat or v)
  );
  # Marks a keybinding as being repeatable (holding the key will trigger the action continuously)
  makeRepeatable = n: { repeat = n; };
in
makeNoRepeat (defaultKeybindings // {
  # Some defaults from Sway are included for the sake of self documentation
  "${modifier}+Return"       = "exec ${binaries.terminal}";
  "${modifier}+Shift+Return" = "exec ${binaries.floating-term}";
  "${modifier}+p"            = "exec ${binaries.menu}";
  "${modifier}+Semicolon"    = "exec ${binaries.emacsclient}";

  "${modifier}+Shift+d" = "kill";
  "${modifier}+Shift+c" = "exec ${getScript "sway-reload.sh"}";

  "${modifier}+Backspace"      = "exec ${binaries.lock}";
  "${modifier}+Ctrl+Backspace" = "exec ${binaries.logout-menu}";

  # Keybinds for modes defined in `modes.nix`
  "${modifier}+r" = "mode resize";
  "${modifier}+g" = "mode gaps";
  "${modifier}+m" = "mode multimedia";
  "${modifier}+x" = "mode execute-focus";

  # Toggle laptop output
  "--locked ${modifier}+Shift+F12" = "output ${OUTPUT-LAPTOP} toggle";

  # Disable defaults (either with a noop or unbind)
  "${modifier}+Shift+e" = null;

  # Pasting (might not work)
  "--release Shift+Insert" = "exec '${binaries.wl-paste} --primary'";

  # Volume stuff
  "--locked XF86AudioRaiseVolume"  = makeRepeatable "exec ${getScript "volume.sh"} 'increase'";
  "--locked XF86AudioLowerVolume"  = makeRepeatable "exec ${getScript "volume.sh"} 'decrease'";
  "--locked XF86AudioMute"         = makeRepeatable "exec ${getScript "volume.sh"} 'toggle-mute'";
  "--locked XF86AudioMicMute"      = makeRepeatable "exec ${getScript "volume.sh"} 'mic-mute'";
  "--locked ${modifier}+Backslash" = makeRepeatable "exec ${getScript "volume.sh"} 'mic-mute'";
  "--locked Scroll_Lock"           = makeRepeatable "exec ${getScript "volume.sh"} 'mic-mute'";

  # Brightness
  "--locked XF86MonBrightnessUp"   = makeRepeatable "exec '${binaries.brightnessctl} set +10%'";
  "--locked XF86MonBrightnessDown" = makeRepeatable "exec '${binaries.brightnessctl} --min-value=30 set 10%-'";

  # Screenshot
  "--release Print"       = "exec ${getScript "screenshot.sh"} 'selection'";
  "--release Alt+Print"   = "exec ${getScript "screenshot.sh"} 'window'";
  "--release Shift+Print" = "exec ${getScript "screenshot.sh"} 'screen'";
  "--release Ctrl+Print"  = "exec ${getScript "screenshot.sh"} 'everything'";

  # Explorer
  "XF86Explorer"            = "exec ${binaries.explorer}";
  "${modifier}+Slash"       = "exec ${binaries.explorer}";
  "${modifier}+Shift+Slash" = "exec ${binaries.explorer}";

  # Browser
  "${modifier}+n"       = "exec ${binaries.browser}";
  "${modifier}+Shift+n" = "exec ${binaries.browser-private}";
  "${modifier}+Ctrl+n"  = "exec ${binaries.browser-work-profile}";

  # MPRIS
  "--locked XF86AudioPause" = "exec ${binaries.playerctl} pause";
  "--locked XF86AudioPlay"  = "exec ${binaries.playerctl} play";
  # Toggle play/pause for the focused? MPRIS instance with PauseBreak
  "--locked Pause"          = "exec ${binaries.playerctl} play-pause";

  # Move windows to the next monitor
  "${modifier}+Ctrl+${left}"  = "move window to output left";
  "${modifier}+Ctrl+${down}"  = "move window to output down";
  "${modifier}+Ctrl+${up}"    = "move window to output up";
  "${modifier}+Ctrl+${right}" = "move window to output right";

  # Multiple monitors command
  # Switch to workspace
  "${modifier}+i" = makeRepeatable "workspace prev_on_output";
  "${modifier}+o" = makeRepeatable "workspace next_on_output";
  # Focus output
  "${modifier}+Shift+i" = makeRepeatable "focus output left";
  "${modifier}+Shift+o" = makeRepeatable "focus output right";
  # Move to workspace
  "${modifier}+Ctrl+i" = "move window to workspace prev_on_output";
  "${modifier}+Ctrl+o" = "move window to workspace next_on_output";
  # Switch focus on workspaces
  "${modifier}+u"       = makeRepeatable "workspace back_and_forth";
  "${modifier}+Shift+u" = "move container to workspace back_and_forth";
  "${modifier}+Ctrl+u"  = "move container to workspace back_and_forth; workspace back_and_forth";

  # Move workspace to other screens
  "${modifier}+Shift+w" = "exec alacritty --class 'floating-term' --command bash '${getScript "sway_move_workspace_to_screen.sh"}'";
  # Move workspace to another screen
  "${modifier}+Alt+w" = "exec '${getScript "sway_move_workspace_to_other_screen.sh"}'";

  # Fullscren inhibits focus
  "${modifier}+f"       = "fullscreen, inhibit_idle focus";
  "${modifier}+Shift+f" = "fullscreen global, inhibit_idle focus";

  "${modifier}+z"       = "focus child";
  "${modifier}+Shift+z" = "focus parent";
  "${modifier}+Shift+s" = "sticky toggle";
  "${modifier}+c"       = "border toggle";

  "${modifier}+1" = "workspace ${ws.WS1}";
  "${modifier}+2" = "workspace ${ws.WS2}";
  "${modifier}+3" = "workspace ${ws.WS3}";
  "${modifier}+4" = "workspace ${ws.WS4}";
  "${modifier}+5" = "workspace ${ws.WS5}";
  "${modifier}+6" = "workspace ${ws.WS6}";
  "${modifier}+7" = "workspace ${ws.WS7}";
  "${modifier}+8" = "workspace ${ws.WS8}";
  "${modifier}+9" = "workspace ${ws.WS9}";
  "${modifier}+0" = "workspace ${ws.WS10}";
  # Move container
  "${modifier}+Shift+1" = "move container to workspace ${ws.WS1}";
  "${modifier}+Shift+2" = "move container to workspace ${ws.WS2}";
  "${modifier}+Shift+3" = "move container to workspace ${ws.WS3}";
  "${modifier}+Shift+4" = "move container to workspace ${ws.WS4}";
  "${modifier}+Shift+5" = "move container to workspace ${ws.WS5}";
  "${modifier}+Shift+6" = "move container to workspace ${ws.WS6}";
  "${modifier}+Shift+7" = "move container to workspace ${ws.WS7}";
  "${modifier}+Shift+8" = "move container to workspace ${ws.WS8}";
  "${modifier}+Shift+9" = "move container to workspace ${ws.WS9}";
  "${modifier}+Shift+0" = "move container to workspace ${ws.WS10}";
  # Move container and focus
  "${modifier}+Ctrl+1" = "move container to workspace ${ws.WS1};  workspace ${ws.WS1}";
  "${modifier}+Ctrl+2" = "move container to workspace ${ws.WS2};  workspace ${ws.WS2}";
  "${modifier}+Ctrl+3" = "move container to workspace ${ws.WS3};  workspace ${ws.WS3}";
  "${modifier}+Ctrl+4" = "move container to workspace ${ws.WS4};  workspace ${ws.WS4}";
  "${modifier}+Ctrl+5" = "move container to workspace ${ws.WS5};  workspace ${ws.WS5}";
  "${modifier}+Ctrl+6" = "move container to workspace ${ws.WS6};  workspace ${ws.WS6}";
  "${modifier}+Ctrl+7" = "move container to workspace ${ws.WS7};  workspace ${ws.WS7}";
  "${modifier}+Ctrl+8" = "move container to workspace ${ws.WS8};  workspace ${ws.WS8}";
  "${modifier}+Ctrl+9" = "move container to workspace ${ws.WS9};  workspace ${ws.WS9}";
  "${modifier}+Ctrl+0" = "move container to workspace ${ws.WS10}; workspace ${ws.WS10}";
})
