{ config, pkgs, options, lib, isLinux, ... }:

with lib;
with builtins;

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

    defaults.file-explorer = mkOption {
      type = types.oneOf [ types.path types.str types.package ];
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

  };

  config = {
    home-manager.users.${config.my.username} = mkAliasDefinitions options.my.home;

    my.defaults.file-explorer = mkIf isLinux "${pkgs.cinnamon.nemo}/bin/nemo";

    home-manager.sharedModules = [{
      imports = (myLib.filesInDir ../modules/home-manager) ++ [ ./home-manager-options.nix ];

      config.my.location = mkForce config.my.location;
      config.my.defaults = mkDefault config.my.defaults;
    }];
  };

}
