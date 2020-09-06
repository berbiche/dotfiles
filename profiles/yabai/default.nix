{ config, pkgs, lib, ... }:

let
  normalize = builtins.mapAttrs (_: v: ({
    string = x: x;
    int = x: x;
    bool = x: if x then "on" else "off";
    float = x: builtins.substring 0 4 (toString x);
  }).${builtins.typeOf v} v);
in
{
  imports = [ ./skhd.nix ];

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    # SIP cannot be disabled
    enableScriptingAddition = lib.mkForce false;
    config = normalize {
      layout = "bsp";
      focus_follows_mouse = "off";
      mouse_follows_focus = false;
      window_placement    = "second_child";
      mouse_modifier      = "cmd";
      mouse_action1       = "move";
      mouse_action2       = "resize";
      mouse_drop_action   = "stack";

      window_topmost      = true;
      window_opacity      = false;
      window_shadow       = true;
      split_ratio         = 0.5;
      auto_balance        = false;
      # Window border is ugly and buggy
      window_border       = false;
      window_border_width = 3;

      active_window_opacity = 1.0;
      normal_window_opacity = 0.8;

      status_bar = false;

      top_padding    = 5;
      bottom_padding = 5;
      left_padding   = 5;
      right_padding  = 5;
      window_gap     = 5;
    };

    extraConfig = ''
      yabai -m rule --add app='^System Preferences$' manage=off
      yabai -m rule --add app="^Digital Colou?r Meter$" sticky=on

      echo "Yabai configuration loaded"
    '';
  };
}
