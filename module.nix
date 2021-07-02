{ config, options, lib, isLinux, ... }:

with lib;

let
  filesInDir = directory:
    let
      files = builtins.readDir directory;
      filteredFiles = filterAttrs (n: v: hasSuffix "nix" n && n != "default.nix") files;
      toPath = map (x: directory + "/${x}");
    in
    assert builtins.isPath directory;
    toPath (attrNames filteredFiles);
in
{
  imports = optionals isLinux (filesInDir ./modules/nixos);

  options.my = {
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
    home-manager.users.${config.my.username} = mkAliasDefinitions options.my.home;

    my.home = { ... }:  {
      imports = filesInDir ./modules/home-manager;

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
    };
  };

}
