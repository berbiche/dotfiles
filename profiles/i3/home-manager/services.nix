{ config, lib, pkgs, ... }:

{
  services.xidlehook = {
    enable = true;
    not-when-fullscreen = true;
    timers = [{
      # 15 minutes
      delay = 60 * 15;
      command = "${pkgs.lightlocker}/bin/light-locker-command -l";
    }];
  };
  systemd.user.services.xidlehook = lib.mkIf config.services.xidlehook.enable {
    Unit.ConditionEnvironment = [ "XDG_CURRENT_DESKTOP=none+i3" ];
    Install.WantedBy = lib.mkForce [ "x11-session.target" ];
  };
}
