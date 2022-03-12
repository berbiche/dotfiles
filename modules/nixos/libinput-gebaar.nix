{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.gebaar-libinput;

  tomlFormat = pkgs.formats.toml { };

  configFile = tomlFormat.generate "gebaard.toml" cfg.settings;
in
{
  options.services.gebaar-libinput = {
    enable = mkEnableOption "Gebaar, a WM independent touchpad gesture daemon for libinput";

    package = mkOption {
      type = types.package;
      default = pkgs.gebaar-libinput;
      defaultText = "pkgs.gebaar-libinput";
      description = ''
        Package to use containing the <command>gebaard</command> application.
      '';
    };

    ydotool = {
      enable = mkEnableOption "ydotool virtual input system service";
      package = mkOption {
        type = types.package;
        default = pkgs.ydotool;
        defaultText = "pkgs.ydotool";
        description = ''
          Package to use containing the <command>ydotoold</command> application.
        '';
      };
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      defaultText = literalExpression "{}";
      description = ''
        Settings for the Gebaar daemon.
        More information about settings can be found on the project's homepage.
      '';
      example = literalExpression ''
        {
          swipe.commands.three = {
            up = "''${pkgs.xdotool}/bin/xdotool key Control_L+equal";
          };
          swipe.commands.four = {
            left = ''${pkgs.xdotool}/bin/xdotool key Super_L+left;
            right = ''${pkgs.xdotool}/bin/xdotool key Super_L+right;
          };
        }
      '';
    };
  };

  config = mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.enable) {
    # https://github.com/NixOS/nixpkgs/issues/70471
    # Chown&chmod /dev/uinput to owner:root group:input mode:0660
    boot.kernelModules = [ "uinput" ];
    services.udev.extraRules = ''
      SUBSYSTEM=="misc", KERNEL=="uinput", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
    '';

    users.users.gebaar-libinput = {
      group = config.users.groups.input.name;
      description = "gebaar-libinput user";
      createHome = false;
      isSystemUser = true;
      inherit (config.users.users.nobody) home;
    };

    systemd.services.gebaar-libinput = {
      description = "Gebaar Daemon touchpad gesture listener";

      partOf = [ "graphical.target" ];
      requires = [ "graphical.target" ];
      after = [ "graphical.target" ] ++ lib.optionals cfg.ydotool.enable [ "ydotoold.service" ];
      wantedBy = [ "graphical.target" ];

      serviceConfig = rec {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/gebaard";
        ExecStartPre = pkgs.writeShellScript "gebaard-start-pre" ''
          ${pkgs.coreutils}/bin/ln -sv "${configFile}" "''${XDG_CONFIG_HOME}/gebaar/gebaard.toml"
        '';
        Restart = "on-failure";
        # The process will exit successfully if it doesn't find a touchpad
        # So we mark at it as "RemainAfterExit" to prevent NixOS
        # from restarting the service on every rebuild
        RemainAfterExit = true;
        User = config.users.users.gebaar-libinput.name;
        Group = config.users.users.gebaar-libinput.group;

        RuntimeDirectory = "gebaar";
        RuntimeDirectoryMode = "0770";
        Environment = [ "XDG_CONFIG_HOME=/run" ];

        # ProtectHome = "read-only";
        # Used in conjunction with ExecStartPre to override the location of Gebaar's home config.
        # PrivateTmp = true;
      };
    };

    # systemd.services.ydotoold = mkIf cfg.ydotool.enable {
    #   description = "Ydotoold virtual input device";

    #   partOf = [ "graphical.target" ];
    #   requires = [ "graphical.target" ];
    #   after = [ "graphical.target" ];
    #   wantedBy = [ "graphical.target" ];

    #   serviceConfig = {
    #     ExecStartPre = pkgs.writeShellScript "delete-ydotool-socket" ''
    #       ${pkgs.coreutils}/bin/rm /tmp/.ydotool_socket || true
    #     '';
    #     ExecStart = "${cfg.ydotool.package}/bin/ydotoold";
    #     ExecStopPost = pkgs.writeShellScript "delete-ydotool-socket" ''
    #       ${pkgs.coreutils}/bin/rm /tmp/.ydotool_socket || true
    #     '';
    #     ExecReload = "systemctl kill --signal=HUP $MAINPID";
    #     KillMode = "process";
    #     TimeoutSec = 100;
    #     Restart = "on-failure";
    #     User = config.users.users.gebaar-libinput.name;
    #     Group = config.users.users.gebaar-libinput.group;

    #     # ProtectHome = "read-only";
    #     # PrivateTmp = true;
    #   };
    # };

    # systemd.sockets.ydotoold = mkIf cfg.ydotool.enable {
    #   description = "Socket for Ydotoold";

    #   partOf = [ "graphical.target" ];
    #   requires = [ "graphical.target" ];
    #   after = [ "graphical.target" ];
    #   wantedBy = [ "graphical.target" ];

    #   # The socket is configurable in ydotoold, but not in the ydotool client
    #   # so it currently serves no purpose: https://github.com/ReimuNotMoe/ydotool/issues/86
    #   listenStreams = [ "/tmp/.ydotool_socket" ];
    # };

  };

  meta.maintainers = with lib.maintainers; [ berbiche ];
}
