final: prev: {
  wlogoutbar = prev.lib.flip prev.callPackage { } (
  { stdenv
  , lib
  , fetchFromGitHub
  , buildGoModule
  , gtk-layer-shell
  , gtk3
  , pkg-config
  }:
  buildGoModule rec {
    pname = "wlogoutbar";
    version = "1.0.1";

    src = fetchFromGitHub {
      repo = pname;
      owner = "berbiche";
      rev = "de58c5b54400645c44ed229a75f5f0e7b708ed80";
      hash = "sha256-a74slXWC0hPHl/Pbj3cbPmvQaT/plN5D4g/kLO+xyY8=";
    };

    vendorSha256 = "sha256-eez6ZaYz7gNXBHaf2eUijQMuM9SFP/ZOmd1z1a5B/OI=";

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [ gtk3 gtk-layer-shell ];

    meta = with lib; {
      description = "Minimal logout bar for Wayland";
      homepage = "https://github.com/berbiche/wlogoutbar";
      license = [ licenses.publicDomain licenses.mit ];
      maintainers = [ maintainers.berbiche ];
    };
  });
}
