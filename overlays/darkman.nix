final: prev: {
  darkman = prev.lib.flip prev.callPackage { } (
  { stdenv
  , lib
  , go
  , fetchFromGitLab
  , buildGoModule
  , gnumake
  , scdoc
  }:

  buildGoModule {
    pname = "darkman";
    version = "v1.0.0";

    src = fetchFromGitLab {
      owner = "WhyNotHugo";
      repo = "darkman";
      rev = "v1.0.0";
      hash = "sha256-eJUFVj0IliIcukcWRU4uFJqE5yu5I7TVIDRnNuMHH6U=";
    };

    vendorSha256 = "sha256-CGgWEaHztWeCQPIrobwLHuDkFauJM19hBU7JsA3HMic=";

    nativeBuildInputs = [ gnumake scdoc ];

    # TODO: Upstream a change that makes use of "$PREFIX/bin/darkman"
    postPatch = ''
      for file in darkman.service contrib/dbus/nl.whynothugo.darkman.service contrib/dbus/org.freedesktop.impl.portal.desktop.darkman.service; do
        substituteInPlace "$file" --replace "/usr/bin/" "$out/bin"
      done
    '';

    makeFlags = [ "PREFIX=${placeholder "out"}" ];

    buildPhase = ''
      runHook preBuild
      mkdir -p $out/bin $out/share
      make build $makeFlags "''${makeFlagsArray[@]}"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make install $makeFlags "''${makeFlagsArray[@]}"
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/darkman --help >/dev/null
    '';

    meta = with lib; {
      description = "Framework for dark-mode and light-mode transitions on Linux desktop";
      homepage = "https://gitlab.com/WhyNotHugo/darkman";
      license = licenses.isc;
      maintainers = [ maintainers.berbiche ];
    };
  });
}
