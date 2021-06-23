{ config, lib, pkgs, ... }:

with lib;

let
  ewwFiles =
    let
      directory = ./.;
      files = builtins.readDir directory;
      filteredFiles = filterAttrs (n: v: v == "regular" && any (flip hasSuffix n) [ "xml" "scss" ]) files;
      toPath = map (x: directory + "/${x}");
      paths = mapAttrs' (n: v: nameValuePair "eww/${n}" { source = toPath n; force = true; }) filteredFiles;
    in
    paths;
in
{
  my.home = { config, ... }: {
    imports = [ ./microphone-indicator.nix ];

    home.packages = [ pkgs.my-nur.eww-wayland ];

    xdg.configFile = ewwFiles // { "eww/.keep" = { source = builtins.toFile "empty" ""; force = true; }; };

    systemd.user.services.eww = {
      Unit = {
        Description = "Customizable Widget system daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        X-Restart-Triggers = mapAttrsToList (_: v: v.source) ewwFiles;
      };
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.my-nur.eww-wayland}/bin/eww daemon";
        EnvironmentFile = "${pkgs.writeShellScript "eww-environment" ''
          export PATH=${lib.escapeShellArg (lib.makeBinPath (with pkgs; [ playerctl curl gnome.nautilus curl ]))}"''${PATH:+:}$PATH"
        ''}";
        Restart = "on-failure";
        RestartSec = "1sec";
        KillMode = "mixed";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    # systemd.user.services.eww-logs = {
    #   Unit = {
    #     Description = "Eww logs streamed to Systemd";
    #     After = [ "eww.service" ];
    #     BindsTo = [ "eww.service" ];
    #     PartOf = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.my-nur.eww-wayland}/bin/eww logs";
    #     Restart = "on-failure";
    #   };
    #   Install.WantedBy = [ "eww.service" ];
    # };
  };
}
