{ ... }:

{
  my.home = { config, lib, pkgs, ... }: {
    # Idle service
    systemd.user.services.sway-idle =
      let
        swaylock  = "${pkgs.swaylock}/bin/swaylock";
        swayidle  = "${pkgs.swayidle}/bin/swayidle";
        swaymsg   = "${pkgs.sway}/bin/swaymsg";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        withPlayerctld = lib.optionalString config.services.playerctld.enable "-p playerctld";
      in
      {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = [ "WAYLAND_DISPLAY" "SWAYSOCK" ];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "1sec";
          # Scripts started by swayidle are executed with 'sh -c'
          Environment = [ "PATH=${dirOf pkgs.stdenv.shell}:$PATH" ];
          ExecStart = ''
            ${swayidle} -w \
                timeout 300  "${swaylock} -f" \
                timeout 600  "${swaymsg} 'output * dpms off'" \
                resume       "${swaymsg} 'output * dpms on'" \
                before-sleep "${playerctl} ${withPlayerctld} pause"\
                before-sleep "${swaylock} -f"
          '';
        };
        Install.WantedBy = [ "sway-session.target" ];
      };
  };
}
