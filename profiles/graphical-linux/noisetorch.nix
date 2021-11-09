{ config, lib, pkgs, ... }:

{
  programs.noisetorch.enable = true;
  # Microphone noise remover
  home-manager.sharedModules = [{
    systemd.user.services.noisetorch = {
      Unit = {
        Description = "noisetorch oneshot loading of microphone suppressor";
        After = lib.optionals config.profiles.pipewire.enable [ "pipewire.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        Requisite = lib.optionals config.profiles.pipewire.enable [ "pipewire.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${config.programs.noisetorch.package}/bin/noisetorch -i";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  }];
}
