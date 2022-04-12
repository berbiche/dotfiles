{ config, lib, pkgs, ... }:

let
  inherit (config.lib.my) getScript;
in
{
  profiles.i3.binaries = rec {
    # Things directly referenced in the config file
    terminal = "${config.my.defaults.terminal} --working-directory ${config.home.homeDirectory}";
    floating-term = "${terminal} --class='floating-term'";
    explorer = "${config.my.defaults.file-explorer}";
    browser = firefox;
    browser-private = "${browser} --private-window";
    browser-work-profile = "${browser} -P job";
    audiocontrol = pavucontrol;
    launcher = menu-ulauncher;
    menu = menu-ulauncher;
    logout = "${pkgs.xfce.xfce4-session}/bin/xfce4-session-logout";
    locker = "${pkgs.lightlocker}/bin/light-locker-command -l";
    screenshot = "${getScript "screenshot.sh"}";
    volume = "${getScript "volume.sh"}";

    menu-ulauncher = "${pkgs.bash}/bin/bash -lc ${pkgs.ulauncher}/bin/ulauncher-toggle";

    light-locker = "${pkgs.lightlocker}/bin/light-locker --idle-hint --lock-on-suspend --lock-after-screensaver=5 --late-locking";

    # Things used by the default commands above (or directly)
    alacritty = "${pkgs.alacritty}/bin/alacritty";
    bitwarden = "${pkgs.bitwarden}/bin/bitwarden";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    emacsclient = "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
    firefox = "${pkgs.firefox}/bin/firefox";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
    spotify = "${pkgs.spotify}/bin/spotify";
    xfce4-appfinder = "${pkgs.xfce.xfce4-appfinder}/bin/xfce4-appfinder";
    xfce4-clipman = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-clipman";
    xfce4-popup-clipman = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-popup-clipman";

    fixXkeyboard = pkgs.writeShellScript "fix-x-keyboard" ''
      xset r rate 200 30
      # setxkbmap -layout us -option ctrl:swapcaps,compose:ralt
    '';
    disableCompositing = pkgs.writeShellScript "disable-xfce-compositing" ''
      xfconf-query -c xfwm4 -p /general/use_compositing -s false
    '';
    startX11SessionTarget = pkgs.writeShellScript "start-x11-session-target" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      systemctl --user import-environment DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      systemctl --user start x11-session.target
    '';
  };
}
