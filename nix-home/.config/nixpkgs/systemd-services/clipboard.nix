pkgs:
{
  clipboard = {
    Unit = {
      Description = "A custom Wayland clipboard manager";
      PartOf= [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      #ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -w /bin/sh -c 'wl-paste -n >> %C/clipboard'";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -w /bin/sh -c " + pkgs.lib.escapeShellArg (pkgs.lib.concatStringsSep "; " [
        "echo $(</dev/stdin) >> %C/clipboard"
        # "echo >> %C/clipboard"
        "${pkgs.gawk}/bin/gawk -i inplace '!seen[$0]++' %C/clipboard"
      ]);
      Restart = "always";
      RestartSec = "5sec";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
