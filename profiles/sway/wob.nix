{ config, lib, pkgs, ... }:

let
  wob = "${pkgs.wob}/bin/wob --timeout=2000 --anchor=top --margin=40";
  startupcmd = (pkgs.writeShellScript "wob-sway" ''
    umask 0177
    rm $XDG_RUNTIME_DIR/wob.sock
    mkfifo $XDG_RUNTIME_DIR/wob.sock
    exec tail -f $XDG_RUNTIME_DIR/wob.sock | ${wob}
  '').overrideAttrs (old: { buildInputs = old.buildInputs or [] ++ [ pkgs.coreutils ]; });
in
{
  my.home = {
    # systemd.user.services.wob = {
    #   Unit = {
    #     Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
    #     Documentation = "man:wob(1)";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #     ConditionEnvironment = "WAYLAND_DISPLAY";
    #   };
    #   Service = {
    #     StandardInput = "socket";
    #     /* Disable pledge because it doesn't work correctly */
    #     Environment = [ "WOB_DISABLE_PLEDGE=1" ];
    #     ExecStart = "${pkgs.wob}/bin/wob -v --timeout=2000 --anchor=top --margin=40";
    #     Restart = "on-failure";
    #     RestartSec = "1sec";
    #   };
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };

    # systemd.user.sockets.wob = {
    #   Socket = {
    #     ListenFIFO = "%t/wob.sock";
    #     SocketMode = "0600";
    #   };
    #   Install.WantedBy = [ "sockets.target" ];
    # };

    # The systemd socket received a lot of garbage for some reason
    # and would randomly block
    wayland.windowManager.sway = {
      config.startup = [{
        command = toString startupcmd;
      }];
    };
  };
}
