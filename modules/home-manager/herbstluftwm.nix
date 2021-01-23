{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.xsession.windowManager.herbstluftwm;

  cfgFile = if isAttrs cfg.config then configToText else cfg.config;

  monitorsToStr =
    concatMapStringsSep "\n" (x: ''
      hc chain add_monitor ${x.rectangle} ${x.tag}, rename_monitor
      ${if isString x then
          x
        else
          ""
        }
    '');

  toLines = concatStringsSep "\n";

  configToText = let
    conf = cfg.config;
    when = optionalString;
  in pkgs.writeText "herbstluftwm-config" ''
    #!${pkgs.stdenv.shell}

    hc() {
      ${cfg.package}/bin/herbstclient "$@"
    }

    # Pre config
    ${cfg.preConfig}
    # User config
    ${when conf.resetKeybindsOnReload "hc keyunbind --all"}
    ${when conf.resetRulesOnReload "hc unrule --all"}
    ${when conf.resetMouseBindingsOnReload "hc mouseunbind --all"}
    ${toLines conf.rules}
    ${toLines conf.tags}
    ${monitorsToStr conf.monitors}
    ${keybindingsToStr conf.keybinds}
    ${mousebindingsToStr conf.mousebinds}
    ${toLines conf.settings}
    # Extra config
    ${cfg.extraConfig}

    # User config (autostart)
    ${when conf.detectMonitors "hc detect_monitors"}

    ${when (conf.startupCommands != [ ]) ''
      if hc silent new_attr bool not_reloading; then
        ${concatStringsSep "\n  " conf.startupCommands}
      fi
    ''}
  '';

  rectangleConfiguration.options = {
  };

  configurationFormat.options = {
    resetKeybindsOnReload = mkEnableOption "resetting previous keybindings on reload";

    resetRulesOnReload = mkEnableOption "resetting rules on reload";

    resetMouseBindingsOnReload = mkEnableOption "resetting mouse bindings on reload";

    detectMonitors = mkEnableOption "herbstluftwm automatic monitor configuration";

    # modifier = mkOption {
    #   description = "Modifier key that is used for default keybindings.";
    # };

    keybinds = mkOption {
      type = types.attrsOf (types.nullOr types.str);
      default = { };
      example = literalExample ''
        {
          "${mod}-f" = "fullscreen toggle";
          "${mod}-space" = "floating toggle";
          "${mod}-Control-h" = "resize left +5";
        }
      '';
      description = "An attribute set that assigns keybindings to an action to execute.";
    };

    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            default = "";
            example = "monitor";
            description = "Monitor name. If this option is set then `tag` must also be set.";
          };

          rectangle = mkOption {
            type = types.either types.str (types.submodule rectangleConfiguration);
            example = "1920x1080+0+0";
            description = "Monitor rectangle.";
          };

          tag = mkOption {
            type = types.str;
            default = "";
            example = "code";
            description = "Default monitor tag to assign.";
          };
        };
      });
      description = ''
        Monitor configuration. Mutually exclusive with `detectMonitors`.
        Setting the list of monitors will remove all previous monitor configuration.
      '';
    };

    rules = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExample ''
        [
          "focus=on"
          "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' pseudotile=on"
          "windowtype~'_NET_WM_WINDOW_TYPE_DIALOG' focus=on"
          "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"
        ]
      '';
      apply = map (x: "hc rule ${x}");
      description = "A list of rules to configure clients.";
    };

    settings = mkOption {
      type = with types; attrsOf (oneOf [ int str bool ]);
      default = { };
      example = literalExample ''
        {
          focus_follows_mouse = 1;
          frame_border_active_color = '#222222';
          window_border_width = 2;
          window_gap = 3;
          frame_bg_transparent = 1;
        }
      '';
      apply = mapAttrsToList (n: v: "hc set ${n} ${v}");
      description = "An attribute set that assigns herbstluftwm settings.";
    };

    startupCommands = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExample ''
        [
          "''${pkgs.nitrogen}/bin/nitrogen --restore &"
          "''${pkgs.dunst}/bin/dunst &"
          "systemctl import-environment DISPLAY XAUTHORITY && systemctl start some-service"
        ]
      '';
      description = ''
        Commands to execute only when starting herbstluftwm.
        The commands are not "spawned" with herbstclient.
        The commands are passed as-is in the script, no escaping (beyond Nix's string escaping)
        is done to the commands.
      '';
    };

    tags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExample ''
        map lib.escapeShellArg [ "1:work" "2:dev" "3:console" ]
      '';
      apply = tags:
        optionals (length tags > 0) (
          [ "hc rename default ${head tags}" ]
          ++ map (x: "hc try silent add ${x}") (tail tags)
        );
      description = ''
        List of tags to create. The first entry will be used as the default tag.
        Tags are not escaped and passed as is in the autostart shell script.
      '';
    };
  };
in
{
  options = {
    enable = mkEnableOption "herbstluftwm window manager";

    package = mkOption {
      type = types.package;
      default = pkgs.herbstluftwm;
      defaultText = "pkgs.herbstluftwm";
      description = "herbstluftwm package to use.";
    };

    commandline = mkOption {
      type = types.either (types.listOf types.str) types.str;
      default = "";
      example = "--no-tag-import --verbose";
      description = "herbstluftwm launch command arguments.";
      apply = cmds:
        if isList cmds then
          concatStringsSep " " cmds
        else
          cmds;
    };

    config = mkOption {
      type = types.either types.path (types.submodule configurationFormat);
      default = { };
      example = literalExample ''
        pkgs.writeText "herbstluftwm-config" '''
          #!''${pkgs.stdenv.shell}
          hc() {
               ''${pkgs.herbstluftwm}/bin/herbstclient "$@"
          }

          if hc silent new_attr bool not_reloading; then
            ''${pkgs.picom}/bin/picom &
            ''${pkgs.dunst}/bin/dunst &
          fi

          hc emit_hook reload
          hc keyunbind --all

          Mod=Mod1

          hc keybind $Mod-Shift-q close
        '''
      '';
      description = ''
        herbstluftwm "autostart" configuration.
        Either a path to a configuration file (the result of a derivation for instance)
        or an attribute set with the configuration.
      '';
    };

    preConfig = mkOption {
      type = types.lines;
      default = "";
      example = "hc lock";
      description = ''
        Extra configuration lines to preprend to the autostart configuration file.
        Incompatible with the `config` option if `config` is not an attribute set.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = "hc unlock";
      description = ''
        Extra configuration lines to append to the autostart configuration file.
        Incompatible with the `config` option if `config` is not an attribute set.
      '';
    };

    finalConfig = mkOption {
      type = types.readonly types.path;
      internal = true;
      # visible = false;
      description = ''
        The final generated configuration as a multiline string.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion =
        ! isAttrs cfg.config -> config.preConfig == "" && config.extraConfig == "";
      message = let
        cfg = "xsession.windowManager.herbstluftwm.config";
      in "The options '${cfg}.preConfig' and '${cfg}.extraConfig'"
         + " are incompatible with '${cfg}.config' when it is not an attribute set.";
    }];

    xsession.windowManager.herbstluftwm.finalConfig = cfgFile;

    home.packages = [ cfg.package ];

    xsession.windowManager.command = "${cfg.package}/bin/herbstluftwm ${cfg.commandline}";

    xdg.configFile."herbstluftwm/autostart" = {
      source = cfgFile;
      onChange = ''
        if [ -n "$DISPLAY" ]; then
          ${cfg.package}/bin/herbstclient reload || true
        fi
      '';
    };
  };
}
