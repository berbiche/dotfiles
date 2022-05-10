{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.profiles.qtile;
in
{
  options.profiles.qtile.enable = mkEnableOption "qtile configuration";

  options.profiles.qtile.binaries = mkOption {
    type = types.attrsOf (types.either types.str types.package);
    apply = s: toString s;
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.qtile ];

    xdg.configFile = lib.mkMerge [
      (lib.listToAttrs (v: {
        name = "qtile/${baseNameOf v}";
        value.source = pkgs.substituteAll (cfg.binaries // {
          src = v;
        });
      }) [
        ./python/config.py
        ./python/traverse.py
        ./python/groups.py
        ./python/keybindings.py
        ./python/settings.py
        ./python/binaries.py
      ])
    ];

    profiles.qtile.binaries = mkDefault rec {
      terminal = "${config.my.defaults.terminal} --working-directory ${config.home.homeDirectory}";
      floating-term = "${terminal} --class='floating-term'";
      explorer = "${config.my.defaults.file-explorer}";
      browser = firefox;
      browser-private = "${browser} --private-window";
      browser-work-profile = "${browser} -P job";
      audiocontrol = pavucontrol;
      launcher = menu-ulauncher;
      menu = menu-ulauncher;
      logout = "${pkgs.gnome.gnome-session}/bin/gnome-session-quit";
      locker = pkgs.writeShellScript "locker" ''
        case "$XDG_CURRENT_DESKTOP" in
          none+*)
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

      light-locker = pkgs.writeShellScript "lockscreen" ''
        if [ "$XDG_CURRENT_DESKTOP" = "none+*" ]; then
          ${pkgs.lightlocker}/bin/light-locker --idle-hint --lock-on-suspend --lock-after-screensaver=5 --late-locking
        fi
      '';

      # Things used by the default commands above (or directly)
      alacritty = "${pkgs.alacritty}/bin/alacritty";
      brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
      emacsclient = "${config.programs.emacs.finalPackage}/bin/emacsclient -c";
      firefox = "${pkgs.firefox}/bin/firefox";
      pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
      playerctl = pkgs.writeShellScript "playerctl" ''
        ${pkgs.playerctl}/bin/playerctl --player=spotify,mpv,firefox "$@"
      '';
      element-desktop = "${pkgs.element-desktop}/bin/element-desktop";
      spotify = "${pkgs.spotify}/bin/spotify";
      unclutter = "${pkgs.unclutter-xfixes}/bin/unclutter --exclude-root";
    };
  };
}
