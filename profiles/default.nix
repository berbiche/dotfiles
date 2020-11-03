let
  # mkLinuxProfile = imports: { stdenv, lib, ... }:
  #   lib.mkIf stdenv.targetPlatform.isLinux { inherit imports; };
  # mkDarwinProfile = imports: { stdenv, lib, ... }:
  #   lib.mkIf stdenv.targetPlatform.isDarwin { inherit imports; };
  mkLinuxProfile = mkProfile;
  mkDarwinProfile = mkProfile;
  mkProfile = imports: { ... }: { inherit imports; };
in
rec {
  dev = mkProfile [ ./dev ];
  programs = mkProfile [ ./programs ];
  ctf = mkProfile [ ./ctf ];

  # Linux only profiles
  core-linux = mkLinuxProfile [ ./core-linux ];
  gnome = mkLinuxProfile [ ./gnome ];
  graphical-linux = mkLinuxProfile [ ./graphical-linux ];
  kde = mkLinuxProfile [ ./kde ];
  obs = mkLinuxProfile [ ./obs ];
  steam = mkLinuxProfile [ ./steam ];
  sway = mkLinuxProfile [ ./sway ];
  xfce = mkLinuxProfile [ ./xfce ];

  # MacOS only profiles
  yabai = mkDarwinProfile [ ./yabai ];

  # Pseudo profiles
  default-linux = mkLinuxProfile [ core-linux dev graphical-linux xfce programs sway ctf ];
}
