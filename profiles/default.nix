{ isLinux ? !isDarwin, isDarwin ? !isLinux }:

# Inlined `assertMsg`
assert (
  if isLinux != isDarwin then
    true
  else
    builtins.throw "profiles: isLinux and isDarwin are mutually exclusive"
  );

let
  # Inlined lib.optionalAttrs
  optionalAttrs = x: y: if x then y else { };
  # Inlined lib.fix
  fix = f: let x = f x; in x;

  mkProfile = imports: let
    # Flattens the list of imports recursively
    flattenImports = imports:
      builtins.foldl' (a: b: a ++ (
        if builtins.isList b
        then flattenImports b
        else if builtins.isAttrs b && b ? imports
        then flattenImports b.imports
        else [ b ])
      ) [ ] imports;
  in {
    imports = flattenImports imports;
  };

  # Constructs an attrset of profiles that export a `home-manager` folder
  # or a `home-manager.nix` file.
  homeManagerImports = profiles: let
    inherit (builtins) attrNames filter foldl' isAttrs pathExists;
    hm = x: let
      y = x + "/home-manager";
    in
      if isAttrs x then null
      else if pathExists y then y
      else if pathExists (y + ".nix") then y + ".nix"
      else null;
  in
    foldl' (a: b: let
      imports = filter (x: x != null) (map hm profiles.${b}.imports);
    in a // optionalAttrs (imports != [ ]) {
      ${b} = { inherit imports; };
    }) { } (attrNames profiles);

  profiles = self:
    {
      base = mkProfile [ ];
      dev = mkProfile [ ./dev ];
      programs = mkProfile [ ./programs ];
      ctf = mkProfile [ ./ctf ];
      secrets = mkProfile [ ./secrets ];
    }
    // optionalAttrs isLinux {
      core-linux = mkProfile [ ./core-linux ./pipewire ];
      gnome = mkProfile [ ./gnome ];
      graphical-linux = mkProfile [ ./graphical-linux ];
      kinect = mkProfile [ ./kinect ];
      obs = mkProfile [ ./obs ];
      steam = mkProfile [ ./steam ];
      sway = mkProfile [ ./i3-sway ./sway ];
      wireguard = mkProfile [ ./wireguard ];
      i3 = mkProfile [ ./i3-sway ./i3 ];
      # Pseudo profiles
      default-linux = mkProfile (with self; [ core-linux dev graphical-linux programs sway ctf secrets ]);
    }
    // optionalAttrs isDarwin {
      core-darwin = mkProfile [ ./core-darwin ];
    };

  profiles' = fix profiles;
in
  profiles' // {
    home-manager = let x = homeManagerImports profiles'; in
      # Yeah.... :)
      builtins.trace ("Available HM profiles: " + (builtins.toString (builtins.attrNames x))) x;
  }
