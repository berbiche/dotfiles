{ config, options, lib, ... }:

{
  options.my = with lib; {
    username = mkOption {
      type = types.str;
      description = "Primary user username";
      example = "nicolas";
      readOnly = true;
    };
    home = mkOption {
      type = options.home-manager.users.type.functor.wrapped;
    };
  };

  config = {
    home-manager.users.${config.my.username} = lib.mkAliasDefinitions options.my.home;
    my.home.options.my.identity = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Fullname";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Email";
      };
      gpgSigningKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Primary GPG signing key";
      };
    };
  };
}
