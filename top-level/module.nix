{ config, pkgs, options, lib, isLinux, ... }:

with lib;
with builtins;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
in
{
  imports = if isLinux then myLib.filesInDir ../modules/nixos else myLib.filesInDir ../modules/darwin;

  options.my = {
    username = mkOption {
      type = types.str;
      description = "Primary user username";
      example = "nicolas";
      readOnly = true;
    };

    # Aliases `my.home` to `home-manager.users.${config.my.username}`.
    # This only aliases the option, the logic to copy the configuration
    # is below in the `config` section.
    home = mkOption {
      type = options.home-manager.users.type.functor.wrapped;
    };

    location = mkOption {
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

    theme.dark = mkOption {
      type = types.str;
      default = "Adwaita-dark";
    };

    theme.light = mkOption {
      type = types.str;
      default = "Adwaita";
    };

    defaults.file-explorer = mkOption {
      type = types.oneOf [ types.path types.str types.package ];
      default = mkIf isLinux "${pkgs.cinnamon.nemo}/bin/nemo";
      defaultText = literalExpression ''
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux "''${pkgs.cinnamon.nemo}/bin/nemo"
      '';
      apply = toString;
      description = "File explorer to use in different applications";
    };

    defaults.terminal = mkOption {
      type = types.oneOf [ types.path types.str types.package ];
      default = "${pkgs.alacritty}/bin/alacritty";
      defaultText = literalExpression ''"''${pkgs.alacritty}/bin/alacritty"'';
      apply = toString;
      description = "File explorer to use in different applications";
    };

    colors = mkOption {
      type = with types; attrsOf (oneOf [ str int float ]);
      description = "Color profile for theming purposes.";
      default = {
        # Stolen from Tristan's config
        color0 = "#1d1f21";
        color1 = "#282a2e";
        color2 = "#373b41";
        color3 = "#969896";
        color4 = "#b4b7b4";
        color5 = "#c5c8c6";
        color6 = "#e0e0e0";
        color7 = "#ffffff";
        color8 = "#cc6666";
        color9 = "#de935f";
        color9Darker = "#ba7c50";
        colorA = "#f0c674";
        colorB = "#b5bd68";
        colorC = "#8abeb7";
        colorD = "#81a2be";
        colorE = "#b294bb";
        colorF = "#a3685a";
      };
    };
  };

  config = {
    home-manager.users.${config.my.username} = mkAliasDefinitions options.my.home;

    home-manager.sharedModules = [{
      imports = myLib.filesInDir ../modules/home-manager;

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
      # mkAliasDefinitions cannot be used for these options
      options.my.colors = options.my.colors;
      options.my.location = options.my.location;
      options.my.theme = options.my.theme;
      options.my.defaults = options.my.defaults;

      config.my.location = mkForce config.my.location;
      config.my.theme = mkForce config.my.theme;
      config.my.defaults = mkForce config.my.defaults;
    }];
  };

}
