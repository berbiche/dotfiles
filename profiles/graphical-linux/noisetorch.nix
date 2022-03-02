{ config, lib, pkgs, ... }:

{
  programs.noisetorch.enable = true;
  # Microphone noise remover
  home-manager.sharedModules = [({ nixosConfig, ...} : {
    systemd.user.services.noisetorch = {
      Unit = {
        Description = "noisetorch oneshot loading of microphone suppressor";
        After = [ "graphical-session.target" ]
          ++ lib.optionals config.profiles.pipewire.enable [ "pipewire.service" "pipewire-pulse.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        Requisite = [ "graphical-session.target" ]
          ++ lib.optionals config.profiles.pipewire.enable [ "pipewire.service" "pipewire-pulse.service" ]
          ++ lib.optionals config.hardware.pulseaudio.enable [ "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${nixosConfig.security.wrapperDir}/${nixosConfig.security.wrappers.noisetorch.program} -i";
        RemainAfterExit = true;
      };
      Install.WantedBy = [ "pipewire-pulse.service" ];
    };
  })];
}
