{ config, pkgs, lib, binaries }:

let
  inherit (config.wayland.windowManager.sway.config)
    modifier
    left
    right
    up
    down;

  getScript = name: ../../scripts + "/${name}";
  OUTPUT-LAPTOP = "eDP-1";
in
lib.mkOptionDefault {
  # Some defaults from Sway are included for the sake of self documentation
  "${modifier}+Return"       = "exec ${binaries.terminal}";
  "${modifier}+Shift+Return" = "exec ${binaries.floating-term}";
  "${modifier}+p"            = "exec ${binaries.menu}";

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
  "${modifier}+Shift+e" = "noop";

  # Pasting (might not work)
  "--release Shift+Insert" = "exec '${binaries.wl-paste} --primary'";

  # Volume stuff
  "--locked XF86AudioRaiseVolume" = "exec ${getScript "volume.sh"} 'increase'";
  "--locked XF86AudioLowerVolume" = "exec ${getScript "volume.sh"} 'decrease'";
  "--locked XF86AudioMute"        = "exec ${getScript "volume.sh"} 'toggle-mute'";
  "--locked XF86AudioMicMute"     = "exec ${getScript "volume.sh"} 'mic-mute'";

  # Brightness
  "--locked XF86MonBrightnessUp"   = "exec '${binaries.brightnessctl} set +10%'";
  "--locked XF86MonBrightnessDown" = "exec '${binaries.brightnessctl} --min-value=30 set 10%-'";

  # Screenshot
  "--release Print"       = "exec ${getScript "screenshot.sh"} 'selection'";
  "--release Alt+Print"  = "exec ${getScript "screenshot.sh"} 'window'";
  "--release Shift+Print" = "exec ${getScript "screenshot.sh"} 'screen'";
  "--release Ctrl+Print"  = "exec ${getScript "screenshot.sh"} 'everything'";

  # Explorer
  "XF86Explorer"            = "exec ${binaries.explorer}";
  "${modifier}+Slash"       = "exec ${binaries.explorer}";
  "${modifier}+Shift+Slash" = "exec ${binaries.explorer}";

  # Browser
  "${modifier}+n"       = "exec ${binaries.browser}";
  "${modifier}+Shift+n" = "exec ${binaries.browser-private}";

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
  "${modifier}+i" = "workspace prev_on_output";
  "${modifier}+o" = "workspace next_on_output";
  # Focus output
  "${modifier}+Shift+i" = "focus output left";
  "${modifier}+Shift+o" = "focus output right";
  # Move to workspace
  "${modifier}+Ctrl+i" = "move window to workspace prev_on_output";
  "${modifier}+Ctrl+o" = "move window to workspace next_on_output";
  # Switch focus on workspaces
  "${modifier}+u"       = "workspace back_and_forth";
  "${modifier}+Shift+u" = "move container to workspace back_and_forth";

  # Move workspace to other screens
  "${modifier}+Shift+w" = "exec alacritty --class 'floating-term' --command bash '${getScript "sway_move_workspace_to_screen.sh"}'";
  # Move workspace to another screen
  "${modifier}+Alt+w" = "exec '${getScript "sway_move_workspace_to_other_screen.sh"}'";

  # Fullscren inhibits focus
  "${modifier}+f"       = "fullscreen, inhibit_idle focus";
  "${modifier}+Shift+f" = "fullscreen global, inhibit_idle focus";

  "${modifier}+z"       = "focus child";
  "${modifier}+Shift+s" = "sticky toggle";

  # Add 10th workspace
  "${modifier}+0"       = "workspace number 10";
  "${modifier}+Shift+0" = "move container to workspace number 10";
  # Move container and focus
  "${modifier}+Ctrl+1"  = "move container to workspace number 1;  workspace number 1";
  "${modifier}+Ctrl+2"  = "move container to workspace number 2;  workspace number 2";
  "${modifier}+Ctrl+3"  = "move container to workspace number 3;  workspace number 3";
  "${modifier}+Ctrl+4"  = "move container to workspace number 4;  workspace number 4";
  "${modifier}+Ctrl+5"  = "move container to workspace number 5;  workspace number 5";
  "${modifier}+Ctrl+6"  = "move container to workspace number 6;  workspace number 6";
  "${modifier}+Ctrl+7"  = "move container to workspace number 7;  workspace number 7";
  "${modifier}+Ctrl+8"  = "move container to workspace number 8;  workspace number 8";
  "${modifier}+Ctrl+9"  = "move container to workspace number 9;  workspace number 9";
  "${modifier}+Ctrl+0"  = "move container to workspace number 10; workspace number 10";
}
