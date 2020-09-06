{ config, pkgs, lib, ... }:

let
  # Exposes yabai and jq to skhd script
  skhd = pkgs.symlinkJoin {
    name = "skhd";
    paths = [ pkgs.skhd ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/skhd --prefix PATH : ${lib.makeBinPath [ pkgs.yabai pkgs.jq ]}
    '';
  };
  # Primary modifier key
  mod = "alt";
  # Secondary modifier key
  sec = "cmd";
  # Directional keys
  left  = "h";
  right = "l";
  down  = "j";
  up    = "k";
  # Other keys
  minus = "0x1B";
  underscore = "shift - ${minus}";
  equal = "0x18";
  plus = "shift - ${equal}";

  binaries = rec {
    terminal = "${alacritty} --working-directory $HOME";

    alacritty = "${pkgs.alacritty}/bin/alacritty";
  };

  # Helpers
  window = f: "yabai -m window ${f}";
  space = f: "yabai -m space ${f}";
  display = f: "yabai -m display ${f}";
  resize = f: "yabai -m window --resize ${f}";
  query = f: "yabai -m query ${f}";
  mkMode = name: shortcut: capture: attrs: let
    toCmd = n: v: let
      sep = if lib.hasPrefix ";" v then "" else ":";
    in "${name} < ${toString n} ${sep} ${v}";
    cmds = lib.mapAttrsToList toCmd attrs;
  in lib.concatStringsSep "\n" [
    ":: ${name} ${if capture then "@" else ""}"
    "${shortcut} ; ${name}"
    (lib.concatStringsSep "\n" cmds)
  ];
  elseJoin = lib.concatStringsSep " || ";
in
{
  environment.systemPackages = [ skhd ];
  services.skhd.enable = true;
  services.skhd.package = skhd;
  services.skhd.skhdConfig = ''
    # Open terminal
    ${mod} - return : ${binaries.terminal}

    # Close focus window
    shift + ${mod} - d : ${window "--close"}
    # Toggle float
    ${mod} - space : ${window "--toggle float"}
    # Toggle sticky
    shift + ${mod} - s : ${window "--toggle sticky"}
    # Toggle fullscreen
    ${mod} - f : ${window "--toggle zoom-fullscreen"}
    # Toggle native-fullscreen
    shift + ${mod} - f : ${window "--toggle native-fullscreen"}
    # Toggle split
    ${mod} - e : ${window "--toggle split"}
    # Toggle stack mode
    ${mod} - s : ${window "--toggle stack"}

    # Focus window
    ${mod} - ${left}  : ${window "--focus west"}
    ${mod} - ${down}  : ${elseJoin [
                          (window "--focus south")
                          (window "--focus stack.next")
                          (window "--focus stack.first")
                        ]}
    ${mod} - ${up}    : ${elseJoin [
                          (window "--focus north")
                          (window "--focus stack.prev")
                          (window "--focus stack.last")
                        ]}
    ${mod} - ${right} : ${window "--focus east"}

    # Move window
    shift + ${mod} - ${left}  : ${window "--warp west"}
    shift + ${mod} - ${down}  : ${window "--warp south"}
    shift + ${mod} - ${up}    : ${window "--warp north"}
    shift + ${mod} - ${right} : ${window "--warp east"}

    # Focus desktop
    ${mod} - i : ${elseJoin [
                    (space "--focus prev")
                    (space "--focus last")
                  ]}
    ${mod} - i : ${elseJoin [
                    (space "--focus next")
                    (space "--focus first")
                  ]}
    ${mod} - 1 : ${space "--focus 1"}
    ${mod} - 2 : ${space "--focus 2"}
    ${mod} - 3 : ${space "--focus 3"}
    ${mod} - 4 : ${space "--focus 4"}
    ${mod} - 5 : ${space "--focus 5"}
    ${mod} - 6 : ${space "--focus 6"}
    ${mod} - 7 : ${space "--focus 7"}
    ${mod} - 8 : ${space "--focus 8"}
    ${mod} - 9 : ${space "--focus 9"}
    ${mod} - 0 : ${space "--focus 10"}

    # Send window to desktop and follow focus
    shift + ${mod} - 1 : ${window "--space  1"}; ${space "--focus 1"}
    shift + ${mod} - 2 : ${window "--space  2"}; ${space "--focus 2"}
    shift + ${mod} - 3 : ${window "--space  3"}; ${space "--focus 3"}
    shift + ${mod} - 4 : ${window "--space  4"}; ${space "--focus 4"}
    shift + ${mod} - 5 : ${window "--space  5"}; ${space "--focus 5"}
    shift + ${mod} - 6 : ${window "--space  6"}; ${space "--focus 6"}
    shift + ${mod} - 7 : ${window "--space  7"}; ${space "--focus 7"}
    shift + ${mod} - 8 : ${window "--space  8"}; ${space "--focus 8"}
    shift + ${mod} - 9 : ${window "--space  9"}; ${space "--focus 9"}
    shift + ${mod} - 0 : ${window "--space 10"}; ${space "--focus 10"}

    # Focus monitor
    shift + ${mod} - i  : ${display "--focus prev"}
    shift + ${mod} - o  : ${display "--focus next"}

    # Send window to monitor
    shift + ${mod} - u  : ${window "--display recent"}; ${display "--focus recent"}

    # Make floating window fill screen
    shift + ${mod} - w : ${window "--grid 1:1:0:0:1:1"}
    # Make floating window fill left-half of screen
    shift + ${mod} - a : ${window "--grid 1:2:0:0:1:1"}
    # Make floating window fill right-half of screen
    shift + ${mod} - d : ${window "--grid 1:2:1:0:1:1"}

    # Gap mode
    ${mkMode "gap" "${mod} - g" true {
      "1" = ''
        ${space "--gap rel:10"}; \
        ${space "--padding abs:0:0:0:0"}; \
        default
      '';
      "2" = ''
        ${space "--gap abs:10"}; \
        ${space "--padding abs:0:0:0:0"}; \
        default
      '';
      "${minus}"      = space "--gap rel:5";
      "${underscore}" = space "--gap rel:-5";
      "${equal}"      = space "--padding rel:5";
      "${plus}"       = space "--padding rel:-5";
      return          = "; default";
      escape          = "; default";
    }}

    # Resize mode
    ${mkMode "resize" "${mod} - r" true (let self = {
      left  = resize "left:-10:0";
      down  = resize "down:0:10";
      up    = resize "up:0:-10";
      right = resize "right:10:0";
      "${left}"  = self.left;
      "${down}"  = self.down;
      "${up}"    = self.up;
      "${right}" = self.right;
      "shift - left"  = resize "left:10:0";
      "shift - down"  = resize "down:0:-10";
      "shift - up"    = resize "up:0:10";
      "shift - right" = resize "right:-10:0";
      "shift - ${left}"  = self."shift - left";
      "shift - ${down}"  = self."shift - down";
      "shift - ${up}"    = self."shift - up";
      "shift - ${right}" = self."shift - right";
      return = "; default";
      escape = "; default";
    }; in self)}

    # Create a new desktop and focus it
    shift + ${mod} - n : ${space "--create"}; \
                         id=$(${query "--displays --display"} | grep "spaces"); \
                         ${space "--focus $(echo \${id:10:\${#id}-10})"}

    ${lib.optionalString false ''
      # Set insertion point in focused container
      ctrl + alt - ${left}  : ${window "--insert west"}
      ctrl + alt - ${down}  : ${window "--insert south"}
      ctrl + alt - ${up}    : ${window "--insert north"}
      ctrl + alt - ${right} : ${window "--insert east"}
    ''}
  '';
}
