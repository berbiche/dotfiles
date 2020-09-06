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

  # Linux only profiles
  core-linux = mkLinuxProfile [ ./core-linux ];
  graphical-linux = mkLinuxProfile [ ./graphical-linux ];
  kde = mkLinuxProfile [ ./kde ];
  gnome = mkLinuxProfile [ ./gnome ];
  sway = mkLinuxProfile [ ./sway ];
  steam = mkLinuxProfile [ ./steam ];

  # MacOS only profiles
  yabai = mkDarwinProfile [ ./yabai ];

  # Pseudo profile
  default-linux = mkLinuxProfile [ core-linux dev graphical-linux kde programs sway ];
}
