#
# Wrapper around xidlehook for home-manager
#
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xidlehook;

  notEmpty = list: filter (x: x != "" && x != null) (flatten list);

  timers =
    let
      toTimer = timer:
        "--timer ${toString timer.delay} ${escapeShellArgs [ timer.command timer.canceller ]}";
    in map toTimer (filter (timer: timer.command != null) cfg.timers);

  script = pkgs.writeShellScript "xidlehook" ''
    ${concatStringsSep "\n"
      (mapAttrsToList (name: value: "export ${name}=${value}") cfg.environment or {})
     }
    ${concatStringsSep " " (notEmpty [
      "${cfg.package}/bin/xidlehook"
      (optionalString cfg.once "--once")
      (optionalString cfg.not-when-fullscreen "--not-when-fullscreen")
      (optionalString cfg.not-when-audio "--not-when-audio")
      timers
    ])}
  '';
in
{
  options.services.xidlehook = {
    enable = mkEnableOption "xidlehook systemd service";

    package = mkOption {
      type = types.package;
      default = pkgs.xidlehook;
      defaultText = "pkgs.xidlehook";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = literalExample ''
        {
          "primary-display" = "$(xrandr | awk '/ primary/{print $1}')";
        }
      '';
      description = ''
        Extra environment options to use in the script.
        These options are passed as <code>export NAME=value</code>, unescaped, in the script.
      '';
    };

    not-when-fullscreen = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Disable locking when a fullscreen application is use";
    };

    not-when-audio = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Disable locking when there's audio playing";
    };

    once = mkEnableOption "running the program once and exiting";

    timers = mkOption {
      type = types.listOf (types.submodule {
        options = {
          delay = mkOption {
            type = types.ints.unsigned;
            example = 60;
            description = "Time before executing the command";
          };
          command = mkOption {
            type = types.nullOr types.str;
            example = literalExample ''
              ''${pkgs.libnotify}/bin/notify-send "Idle" "Sleeping in 1 minute"
            '';
            description = "Command executed after the idle timeout is reached";
          };
          canceller = mkOption {
            type = types.str;
            default = "";
            example = literalExample ''
              ''${pkgs.libnotify}/bin/notify-send "Idle" "Resuming activity"
            '';
            description = ''
              Command executed when the user becomes active once again.
              This is only executed if the next timer is not reached.
            '';
          };
        };
      });
      default = [ ];
      example = literalExample ''
        [
          {
            delay = 60;
            command = "xrandr --output \"$PRIMARY_DISPLAY\" --brightness .1";
            canceller = "xrandr --output \"$PRIMARY_DISPLAY\" --brightness 1";
          }
          {
            delay = 120;
            command = "''${pkgs.writeScript "my-script" '''
              # A complex script to run
            '''}";
          }
        ]
      '';
      description = ''
        A set of commands to be executed after a specific idle timeout.
        The commands specified in <code>command</code> and <code>canceller</code>
        are passed escaped to the script.
        To use or re-use environment variables that are script-dependent, specify them
        in the <code>environment</code> section.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.xidlehook = {
      Unit = {
        Description = "xidlehook service";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = if cfg.once then "oneshot" else "simple";
        ExecStart = "${script}";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    ## TODO
    # systemd.user.sockets.xidlehook = {

    # };
  };
}
