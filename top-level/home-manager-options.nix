{ pkgs, lib, ... }:

with lib;

{
  options.my.identity = {
    name = mkOption {
      type = types.str;
      description = "Fullname";
    };
    email = mkOption {
      type = types.str;
      description = "Email";
    };
    gpgSigningKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Primary GPG signing key";
    };
  };

  options.my.location = mkOption {
    type = types.nullOr (types.submodule {
      options.longitude = mkOption {
        type = types.float;
      };
      options.latitude = mkOption {
        type = types.float;
      };
    });
    default = null;
  };
  options.my.defaults.file-explorer = mkOption {
    type = types.oneOf [ types.path types.str types.package ];
    apply = toString;
    description = "File explorer to use in different applications";
  };

  options.my.defaults.terminal = mkOption {
    type = types.oneOf [ types.path types.str types.package ];
    default = "${pkgs.alacritty}/bin/alacritty";
    defaultText = literalExpression ''"''${pkgs.alacritty}/bin/alacritty"'';
    apply = toString;
    description = "File explorer to use in different applications";
  };

  options.my.theme = {
    package = mkOption {
      type = types.package;
      default = pkgs.gnome-themes-standard;
    };
    dark = mkOption {
      type = types.str;
      default = "Adwaita-dark";
    };
    light = mkOption {
      type = types.str;
      default = "Adwaita";
    };
    cursor.name = mkOption {
      type = types.str;
      example = "Adwaita";
    };
    cursor.size = mkOption {
      type = types.ints.positive;
      example = 24;
    };
  };

  options.my.colors = mkOption {
    type = with types; attrsOf (oneOf [ str int float ]);
    description = "Color profile for theming purposes.";
  };
}
