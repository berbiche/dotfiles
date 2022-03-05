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
      rev = "561eab773a37e2791c59794da6b653a8c0577da7";
      hash = "sha256-VYzyybzqMW+J+EUGPZz3+V9s6LWXrg4Z4x6PTkWsuXc=";
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
