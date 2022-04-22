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
    locker = pkgs.writeShellScript "i3-locker" ''
      case "$XDG_CURRENT_DESKTOP" in
        none+i3)
          ${pkgs.lightlocker}/bin/light-locker-command -l
          ;;
        GNOME-Flashback*)
          ${pkgs.dbus.out}/bin/dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock
          ;;
      esac
    '';
    screenshot = "${getScript "screenshot.sh"}";
    volume = "${getScript "volume.sh"}";

    menu-ulauncher = "${pkgs.bash}/bin/bash -lc ${pkgs.ulauncher}/bin/ulauncher-toggle";

    light-locker = pkgs.writeShellScript "i3-lockscreen" ''
      if [ "$XDG_CURRENT_DESKTOP" = "none+i3" ]; then
        ${pkgs.lightlocker}/bin/light-locker --idle-hint --lock-on-suspend --lock-after-screensaver=5 --late-locking
      fi
    '';

    # Things used by the default commands above (or directly)
    alacritty = "${pkgs.alacritty}/bin/alacritty";
    bitwarden = "${pkgs.bitwarden}/bin/bitwarden";
    brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
    emacsclient = "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
    firefox = "${pkgs.firefox}/bin/firefox";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
    # i3 and Sway don't parse quotes correctly so the commas in the command below
    # are parsed as i3/sway command separators.
    # The solution is to use a wrapper script
    playerctl = pkgs.writeShellScript "i3-playerctl" ''
      ${pkgs.playerctl}/bin/playerctl --player=spotify,mpv,firefox "$@"
    '';
    element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
    spotify = "${pkgs.spotify}/bin/spotify";
    unclutter = "${pkgs.unclutter-xfixes}/bin/unclutter --exclude-root";
    xfce4-appfinder = "${pkgs.xfce.xfce4-appfinder}/bin/xfce4-appfinder";
    xfce4-clipman = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-clipman";
    xfce4-popup-clipman = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-popup-clipman";

    disableCompositing = pkgs.writeShellScript "disable-xfce-compositing" ''
      xfconf-query -c xfwm4 -p /general/use_compositing -s false || true
    '';
    startX11SessionTarget = pkgs.writeShellScript "start-x11-session-target" ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      systemctl --user import-environment DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP
      systemctl --user start x11-session.target
    '';

    # The ~/.background-image should automatically be picked up by NixOS
    # but it's not the case for whatever reason.
    wallpaper = pkgs.writeShellScript "i3-wallpaper" ''
      if [ "$XDG_CURRENT_DESKTOP" = "none+i3" ]; then
        ${pkgs.feh}/bin/feh --bg-scale ~/.background-image
      fi
    '';
    # The top gaps is only used for the polybar hack
    override-gaps-settings = pkgs.writeShellScript "i3-override-gaps" ''
      if [[ "$XDG_CURRENT_DESKTOP" =~ "GNOME-Flashback" ]]; then
        ${pkgs.i3}/bin/i3-msg gaps top all set 0
      fi
    '';
  };
}
