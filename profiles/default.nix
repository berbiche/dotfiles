rec {
  core-linux = { ... }: { imports = [ ./core-linux ]; };
  dev = { ... }: { imports = [ ./dev ]; };
  graphical-linux = { ... }: { imports = [ ./graphical-linux ]; };
  programs = { ... }: { imports = [ ./programs ]; };
  sway = { ... }: { imports = [ ./sway ]; };
}
