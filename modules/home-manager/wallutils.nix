{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.wallutils;

  modeOption = mkOption {
    type = types.either (types.enum [ "stretch" "center" "tile" "scale" ]) types.str;
    default = "stretch";
    description = "Wallpaper mode";
  };
in
{
  options.services.wallutils = {
    enable = mkEnableOption "Wallutils automatic wallpaper tool";

    package = mkOption {
      type = types.package;
      default = pkgs.wallutils;
      defaultText = "pkgs.wallutils";
    };

    timed = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Systemd service for the timed wallpaper";

          theme = mkOption {
            type = types.path;
            example = "mojave-timed";
            description = ''
              Name or path of the timed wallpaper.
              If the filename contains an extension, then it must be one of
              <code>.xml</code> or <code>.stw</code>.
            '';
          };

          mode = modeOption;
        };
      };
      default = { };
      example = literalExpression ''
        {
          enable = true;
          theme = "''${pkgs.gnome3.gnome-backgrounds}/share/backgrounds/gnome/adwaita-timed.xml";
          mode = "stretch";
        }
      '';
    };

    static = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Systemd service to set the wallpaper";

          image = mkOption {
            type = types.str;
            example = "\${config.home.homeDirectory}/Pictures/my-wallpaper.png";
            description = "Path or URL of the wallpaper";
          };

          downloadDir = mkOption {
            type = types.nullOr types.path;
            default = null;
            example = "\${config.home.homeDirectory}/Downloads";
            description = "Path to the download directory for URL wallpapers";
          };

          mode = modeOption;
        };
      };
      default = { };
      example = literalExpression ''
        {
          enable = true;
          image = "https://source.unsplash.com/3840x2160/?mountains";
          mode = "stretch";
          downloadDir = "/tmp/wallpapers";
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = ! (cfg.timed.enable && cfg.static.enable);
      message = "Wallutils timed and static wallpapers are mutually exclusive."
                + " Either one may be enable, not both.";
    }];

    systemd.user.services.wallutils-timed = mkIf cfg.timed.enable {
      Unit = {
        Description = "Wallutils timed wallpaper service";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        Environment = "PATH=${config.home.profileDirectory}/bin";
        ExecStart = "${cfg.package}/bin/settimed --mode ${cfg.timed.mode} ${cfg.timed.theme}";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.services.wallutils-static = mkIf cfg.static.enable {
      Unit = {
        Description = "Wallutils static wallpaper service";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        Environment = "PATH=${config.home.profileDirectory}/bin";
        ExecStart = concatStringsSep " " [
          "${cfg.package}/bin/setwallpaper"
          "--mode ${cfg.static.mode}"
          (optionalString (cfg.static.downloadDir != null) "--download ${escapeShellArg cfg.static.downloadDir}")
          "${cfg.static.image}"
        ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
