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
    colors = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.int types.float ]);
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
      options.my.colors = options.my.colors;
    };
  };

}
