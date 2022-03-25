/*
  This overlay overrides Sway's startup command to output
  to the systemd log using systemd-cat
*/
final: prev: {
  # sway-unwrapped = prev.sway-unwrapped.overrideAttrs (drv: {
  #   src = prev.fetchFromGitHub {
  #     owner = "swaywm";
  #     repo = "sway";
  #     rev = "68a3c06bb6043919b14f810a63a8a7c0a8deb202";
  #     hash = "sha256-GJBMUMtvBqBOnWuI3xmX61nag1qRJPkA4F5aYo5Hf2A=";
  #   };
  # });
  sway = prev.lib.flip prev.callPackage { } (
    { lib
    , sway-unwrapped, systemd
    , makeWrapper, symlinkJoin, writeShellScriptBin
    , withBaseWrapper ? true, extraSessionCommands ? "", dbus
    , withGtkWrapper ? false, wrapGAppsHook, gdk-pixbuf, glib, gtk3
    , extraOptions ? [] # E.g.: [ "--verbose" ]
    # Used by the NixOS module:
    , isNixOS ? false

    , enableXWayland ? true
    }:

    assert extraSessionCommands != "" -> withBaseWrapper;

    with lib;

    let
      sway = sway-unwrapped.override { inherit isNixOS enableXWayland; };
      baseWrapper = writeShellScriptBin "sway" ''
         set -o errexit
         if [ ! "$_SWAY_WRAPPER_ALREADY_EXECUTED" ]; then
           export XDG_CURRENT_DESKTOP=sway
           ${extraSessionCommands}
           export _SWAY_WRAPPER_ALREADY_EXECUTED=1
         fi
         if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
           export DBUS_SESSION_BUS_ADDRESS
           exec ${systemd}/bin/systemd-cat -t sway ${sway}/bin/sway "$@"
         else
           exec ${dbus}/bin/dbus-run-session ${systemd}/bin/systemd-cat -t sway ${sway}/bin/sway "$@"
         fi
       '';
    in symlinkJoin {
      name = "sway-${sway.version}";

      paths = (optional withBaseWrapper baseWrapper)
        ++ [ sway ];

      nativeBuildInputs = [ makeWrapper ]
        ++ (optional withGtkWrapper wrapGAppsHook);

      buildInputs = optionals withGtkWrapper [ gdk-pixbuf glib gtk3 ];

      # We want to run wrapProgram manually
      dontWrapGApps = true;

      postBuild = ''
        ${optionalString withGtkWrapper "gappsWrapperArgsHook"}

        wrapProgram $out/bin/sway \
          ${optionalString withGtkWrapper ''"''${gappsWrapperArgs[@]}"''} \
          ${optionalString (extraOptions != []) "${concatMapStrings (x: " --add-flags " + x) extraOptions}"}
      '';

      passthru.providedSessions = [ "sway" ];

      inherit (sway) meta;
    });
}
