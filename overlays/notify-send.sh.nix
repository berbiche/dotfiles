final: prev:
let
  inherit (prev) fetchFromGitHub lib stdenv makeWrapper;

  # 2020-11-16
  revision = "3bf1e44ffedee94357a0ede7b2672846c60bb1a9";

  path = lib.makeBinPath (with prev; [ glib.bin gnused ]);
in
{
  notify-send_sh = stdenv.mkDerivation {
    pname = "notify-send.sh";
    version = builtins.substring 0 8 revision;

    src = fetchFromGitHub {
      owner = "vlevit";
      repo = "notify-send.sh";
      rev = revision;
      hash = "sha256-gNByekfnRuO3VvoyAC+/8Re5j20+fdpHEmOBk8FSbc0=";
    };

    nativeBuildInputs = [ makeWrapper ];

    dontConfigure = true;
    dontBuild = true;

    patchPhase = ''
      sed -i 's|\^GDBUS_MONITOR_PID=.*|GDBUS_MONITOR_PID="''${TMPDIR:-''${TEMP:-''${TMP:-/tmp}}}/notify-action-dbus-monitor.$$.pid"|' \
        notify-action.sh
    '';

    installPhase = ''
      install -d $out/bin
      install -Dm0755 notify-action.sh notify-send.sh $out/bin

      for i in $out/bin/*; do
        wrapProgram "$i" --prefix PATH : "${path}"
      done
    '';

    meta = with lib; {
      description = "A drop-in replacement for notify-send with more features";
      homepage = "https://github.com/vlevit/notify-send.sh";
      license = licenses.gpl3;
      maintainer = with maintainers; [ berbiche ];
    };
  };
}
