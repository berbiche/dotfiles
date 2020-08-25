rec {
  core-linux = { ... }: { imports = [ ./core-linux ] };
  graphical-linux = { ... }: { imports = [ ./graphical-linux ]; };
  programs = { ... }: { imports [ ./programs ]; };
  sway = { ... }: { imports = [ ./sway ]; };
}