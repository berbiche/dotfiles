{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.swayidle;

  durationFormat = "([[:digit:]]+)[[:space:]]*(s$|seconds?$|m$|minutes?$|h$|hours?$)";
  durationToSecond = duration:
    let
      duration' = builtins.match durationFormat duration;
      time = head duration';
      format = substring 0 1 (last duration');
    in
    if isInt duration then
      toString time
    else if format == "s" then
      time
    else if format == "m" then
      toString (toInt time * 60)
    else if format == "h" then
      toString (toInt time * 3600)
    else
      throw "unsupported time specifier '${last duration'}'";

  commandToStr = x: escapeShellArg (concatStringsSep "; " (toList x));

  timeoutToStr = x:
    "timeout ${durationToSecond x.timeout} ${commandToStr x.command}"
    + (optionalString (x.resume != null) " resume ${commandToStr x.resume}");

  timeoutSubmodule = types.submodule {
    options.timeout = mkOption {
      type = types.oneOf [ (types.strMatching durationFormat) types.ints.positive ];
      example = 300;
      description = ''
        How long to wait, in seconds, without any user activity, before executing the command.
        Alternatively, the timeout period can be specified using a duration format like <literal>300 seconds</literal>.
        </para><para>
        The format accepts the following variants, whitespace is optional:
        <itemizedlist>
          <listitem><para><literal>1 s</literal></para></listitem>
          <listitem><para><literal>1 second</literal></para></listitem>
          <listitem><para><literal>1 seconds</literal></para></listitem>
          <listitem><para><literal>1 m</literal></para></listitem>
          <listitem><para><literal>1 minute</literal></para></listitem>
          <listitem><para><literal>1 minutes</literal></para></listitem>
          <listitem><para><literal>1 h</literal></para></listitem>
          <listitem><para><literal>1 hour</literal></para></listitem>
          <listitem><para><literal>1 hours</literal></para></listitem>
        </itemizedlist>
      '';
    };
    options.command = mkOption {
      type = types.either types.str (types.listOf types.str);
      example = "\${pkgs.swayidle}/bin/swayidle -f";
      description = ''
        Commands to execute after the inactivity timeout.
        </para><para>
        Commands are escaped.
      '';
    };
    options.resume = mkOption {
      type = types.nullOr (types.either types.str (types.listOf types.str));
      default = null;
      example = "\${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      description = ''
        Commands to execute after user activity is detected again.
        This will only run if the activity timeout was reached previously.
        </para><para>
        Commands are escaped.
      '';
    };
  };

  mkCommandOption = x: mkOption {
    type = types.either types.str (types.listOf types.str);
    default = [ ];
    example = literalExample ''
      [
        "''${pkgs.playerctl}/bin/playerctl --all-players pause"
        "''${pkgs.swaylock}/bin/swaylock -f"
      ]
    '';
    description = x;
  };
in
{
  options.services.swayidle = {
    enable = mkEnableOption "idle manager for Wayland";

    wait-for-command-completion = mkEnableOption "waiting for commands to finish before continuing" // { default = true; };

    package = mkOption {
      type = types.package;
      default = pkgs.swayidle;
      defaultText = literalExample "pkgs.swayidle";
      description = "Package to use.";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      defaultText = literalExample "[ ]";
      example = literalExample ''
        [
          "-d"
          "-S seat0"
        ]
      '';
      description = "Extra arguments to pass to <command>swayidle</command>";
    };

    idlehint = mkOption {
      type = types.nullOr (types.either types.ints.positive (types.strMatching durationFormat));
      default = null;
      example = 300;
      description = ''
        Whether to mark the logind/elogind session idle after <literal>idlehint</literal> milliseconds.
        This option accepts the same duration format as <option>services.swayidle.timeout.*.timeout</option>
      '';
    };

    timeout = mkOption {
      type = types.listOf timeoutSubmodule;
      default = [ ];
      defaultText = literalExample "[ ]";
      example = literalExample ''
        [
          {
            timeout = 300;
            command = "''${pkgs.swayidle}/bin/swayidle -f";
          }
          {
            timeout = 600;
            command = "true";
            resume  = "''${pkgs.dunst}/bin/dunstctl set-paused false";
          }
        ]
      '';
      description = ''
        Timeout event commands. Note that the order is important and that
        the total timeout is cumulative. In other words, a timeout of <literal>300</literal> for the first command
        followed by a timeout of <literal>600</literal> for the second command will result in a timeout of <literal>900</literal>
        for the second command.
      '';
    };

    before-sleep = mkCommandOption "Commands to execute before sleeping.";

    after-resume = mkCommandOption "Commands to execute after resuming from sleep.";

    lock = mkCommandOption "Commands to execute after the session is locked.";

    unlock = mkCommandOption "Commands to execute after the session is unlocked.";
  };

  config = let
    formatCommand = cmd: commands:
      optionalString (commands != []) (concatMapStringsSep "\n" (x: "${cmd} ${commandToStr x}") commands);

    finalConfig = pkgs.writeText "swayidle-config" ''
      ${optionalString (cfg.idlehint != null) "idlehint ${durationToSecond cfg.idlehint}"}
      ${concatMapStringsSep "\n" timeoutToStr cfg.timeout}
      ${formatCommand "before-sleep" cfg.before-sleep}
      ${formatCommand "after-resume" cfg.before-sleep}
      ${formatCommand "lock" cfg.before-sleep}
      ${formatCommand "unlock" cfg.before-sleep}
    '';

    finalCommand = concatStringsSep " " [
      "${cfg.package}/bin/swayidle"
      (optionalString cfg.wait-for-command-completion "-w")
      (escapeShellArgs cfg.extraArgs)
      "-C ${finalConfig}"
    ];
  in
  mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."swayidle/config".source = finalConfig;

    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
        Requisite = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "1sec";
        # Scripts started by swayidle are executed with 'sh -c'
        Environment = [ "PATH=${dirOf pkgs.stdenv.shell}:$PATH" ];
        ExecStart = finalCommand;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
