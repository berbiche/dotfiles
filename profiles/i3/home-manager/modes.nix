{ config, lib, pkgs, ... }:

let
  inherit (config.profiles.i3) binaries;
  inherit (config.xsession.windowManager.i3.config) modifier;
in
{
  xsession.windowManager.i3.config.modes = {
    resize = {
      "h"  = "resize shrink width 10 px";
      "j"  = "resize grow height 10 px";
      "k"    = "resize shrink height 10 px";
      "l" = "resize grow width 10 px";
      Left  = "resize shrink width 10 px";
      Down  = "resize grow height 10 px";
      Up    = "resize shrink height 10 px";
      Right = "resize grow width 10 px";

      Escape = "mode default";
      Return = "mode default";
    };

    execute-focus = {
      # Spotify
      s = ''[class="(?i)Spotify"] focus; mode default'';
      # Riot/Element
      r = ''[class="(?i)Element"] focus; mode default'';
      # Bitwarden
      b = ''[class="(?i)Bitwarden" instance="bitwarden"] focus; mode default'';
      # Discord
      d = ''[class="(?i)discord"] focus; mode default'';
      # Emacs
      e = ''[class="(?i)emacs"] focus; mode default'';
      # Pavucontrol
      c = "exec ${binaries.audiocontrol}; mode default";

      Return = "mode default";
      Escape = "mode default";
    };
  };

  xsession.windowManager.i3.config.keybindings = {
    "${modifier}+r" = "mode resize";
    "${modifier}+x" = "mode execute-focus";
  };
}
