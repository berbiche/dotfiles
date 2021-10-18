{ isLinux ? !isDarwin, isDarwin ? !isLinux }:

# Inlined `assertMsg`
assert (
  if isLinux != isDarwin then
    true
  else
    builtins.trace "profiles: isLinux and isDarwin are mutually exclusive" false
  );

let
  # Inlined lib.optionalAttrs
  optionalAttrs = x: y: if x then y else { };
  # Inlined lib.fix
  fix = f: let x = f x; in x;

  mkProfile = imports: { ... }: { inherit imports; };

  profiles = self:
    {
      base = mkProfile [ ];
      dev = mkProfile [ ./dev ];
      programs = mkProfile [ ./programs ];
      ctf = mkProfile [ ./ctf ];
      secrets = mkProfile [ ./secrets ];
    }
    // optionalAttrs isLinux {
      core-linux = mkProfile [ ./core-linux ./pipewire ./email ];
      gnome = mkProfile [ ./gnome ];
      graphical-linux = mkProfile [ ./graphical-linux ];
      kde = mkProfile [ ./kde ];
      kinect = mkProfile [ ./kinect ];
      obs = mkProfile [ ./obs ];
      steam = mkProfile [ ./steam ];
      sway = mkProfile [ ./sway ];
      wireguard = mkProfile [ ./wireguard ];
      xfce = mkProfile [ ./xfce ];
      # Pseudo profiles
      default-linux = mkProfile (with self; [ core-linux dev graphical-linux programs sway ctf secrets ]);
    }
    // optionalAttrs isDarwin {
      core-darwin = mkProfile [ ./core-darwin ];
      yabai = mkProfile [ ./yabai ];
    };
in
  fix profiles
