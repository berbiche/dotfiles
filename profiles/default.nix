rec {
  core-linux = { ... }: { imports = [ ./core-linux ]; };
  dev = { ... }: { imports = [ ./dev ]; };
  graphical-linux = { ... }: { imports = [ ./graphical-linux ]; };
  kde = { ... }: { imports = [ ./kde ]; };
  gnome = { ... }: { imports = [ ./gnome ]; };
  programs = { ... }: { imports = [ ./programs ]; };
  sway = { ... }: { imports = [ ./sway ]; };
  steam = { ... }: { imports = [ ./steam ]; };

  # Pseudo profile
  default-linux = { ... }: { imports = [ core-linux dev graphical-linux kde programs sway ]; };
}
