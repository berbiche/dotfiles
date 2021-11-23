{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.wlogout;

  # We won't be using the generate method because
  # wlogout expects json objects to be at the top level
  # and not nested in an array
  json = pkgs.formats.json { };

  # This is exactly like `pkgs.formats.json.generate` except we remove
  # the array wrapping the list.
  # wlogout accepts a list of object separated by an optional comma (a "json line" file)
  generateLayout = name: value: pkgs.runCommandLocal name {
    nativeBuildInputs = [ pkgs.jq ];
    value = builtins.toJSON value;
    passAsFile = [ "value" ];
  } ''
    jq '.[]' "$valuePath"> $out
  '';

  floatBetween = x: y: types.addCheck types.float (z: z <= x && z <= y);

  layoutType = with types; submodule {
    # In case new settings are ever added
    freeformType = nullOr (oneOf [ float int str ]);
    options = {
      label = mkOption {
        type = str;
        example = "sleep";
        description = "CSS selector used that can be used for theming.";
      };
      action = mkOption {
        type = str;
        example = literalExpression ''
          "$${pkgs.systemd}/bin/systemctl suspend-then-hibernate"
        '';
        description = "Action to invoke when clicking the button or using the associated keybind.";
      };
      text = mkOption {
        type = str;
        example = "sleep";
        description = "Text to display with the button. Leave empty to show no text.";
      };
      keybind = mkOption {
        type = str;
        example = "h";
        description = "Key to use to invoke the associated action.";
      };
      height = mkOption {
        type = nullOr (floatBetween 0 1);
        default = null;
        example = 0.0;
        description = ''
          Vertical placement of the text relative to the button.
          </para>
          <para
          This value must be between <literal>0.0</literal> and <literal>1.0</literal>.
          </para>
          <para>
          A value of <literal>0.5</literal> will vertically center the text in the button.
          A value of <literal>0</literal> will align the text to the bottom of the button.
        '';
      };
      width = mkOption {
        type = nullOr (floatBetween 0 1);
        default = null;
        defaultText = "null";
        example = 0.5;
        description = ''
          Horizontal placement of the text relative to the button.
          </para>
          <para
          This value must be between <literal>0.0</literal> and <literal>1.0</literal>.
          </para>
          <para>
          A value of <literal>0.5</literal> will horizontally center the text in the button.
          A value of <literal>0</literal> will align the text to the left of the button.
        '';
      };
      circular = mkOption {
        type = nullOr bool;
        default = null;
        defaultText = "null";
        example = literalExpression "true";
        description = "Whether to make the button round.";
      };
    };
  };
in
{
  options.programs.wlogout = {
    enable = mkEnableOption "wlogout, a wayland based logout menu";

    package = mkOption {
      type = types.package;
      default = pkgs.wlogout;
      defaultText = literalExpression "pkgs.wlogout";
      description = "Package providing the <command>wlogout</command> program.";
    };

    layouts = mkOption {
      type = types.attrsOf (types.listOf layoutType);
      default = { };
      defaultText = "{ }";
      example = literalExpression ''
        {
          # This is the default layout
          "layout" = [
            {
              label = "lock";
              text = "Lock";
              # Note that swaylock needs PAM permissions
              # See https://github.com/nix-community/home-manager/issues/1288
              action = "$${pkgs.swaylock}/bin/swaylock";
              keybind = "l";
              circular = true;
            }
            {
              label = "logout";
              text = "Logout";
              action = "$${pkgs.systemd}/bin/loginctl terminate-user $USER";
              keybind = "K";
              circular = true;
            }
          ];
          # This can be used with `wlogout --layout "$XDG_CONFIG_HOME/wlogout/another-layout"`
          "another-layout" = [
            {
              label = "action-1";
              text = "Perform action 1";
              action = "echo doing action 1";
              keybind = "a";
            }
          ];
        }
      '';
      description = ''
        An attribute set of filenames to a list of layouts.
        </para>
        <para>
        The default layout used by wlogout is <filename>layout</filename> and its
        associated styling file is <filename>style.css</filename>.
        If no layout is specified, wlogout will use its own default layout.
        </para>
        <para>
        The layout format is described in
        <citerefentry>
          <refentrytitle>wlogout</refentrytitle>
          <manvolnum>5</manvolnum>
        </citerefentry>.
      '';
    };

    themes = mkOption {
      type = types.attrsOf (types.either types.lines types.path);
      default = { };
      example = literalExpression ''
        {
          "style.css" = '''
            .lock {
              background: red;
            }
          ''';
          "alternate.css" = ./alternate.css;
        }
      '';
      description = ''
        An attribute set of filenames to CSS themes.
        </para>
        <para>
        The default styling file used by wlogout is <filename>style.css</filename>.
        If no theme is specified, wlogout will use its own default layout.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = let
      layoutFiles = mapAttrs' (file: layout: nameValuePair "wlogout/${file}" {
        source = generateLayout "wlogout-${file}" (map (filterAttrs (_n: v: v != null)) layout);
      }) cfg.layouts;

      cssFiles = mapAttrs' (file: theme: nameValuePair "wlogout/${file}" (
        if isPath theme then
          { source = theme; }
        else
          { text = theme; }
        )) cfg.themes;
    in mkMerge [
      layoutFiles
      cssFiles
    ];
  };
}
