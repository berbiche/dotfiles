final: prev: {
  asroute = prev.lib.flip prev.callPackage { } (
  { stdenv
  , lib
  , fetchFromGitHub
  , rustPlatform
  }:
  rustPlatform.buildRustPackage rec {
    pname = "asroute";
    version = "0.1.0";

    src = fetchFromGitHub {
      repo = pname;
      owner = "stevenpack";
      rev = "v${version}";
      hash = "sha256-+H3AYe+OWrxxaJ78ofuivz7DB/Fi8voZQyb1p2cCAns=";
    };

    cargoHash = "sha256-ZZz5i415lHWHVBL+Abe5C7gVjwm7/mbJ6I+/mp/96vI=";

    meta = with lib; {
      description = "Interpret traceroute output to show names of ASN traversed";
      homepage = src.meta.homepage;
      license = [ licenses.mit ];
      maintainers = [ maintainers.berbiche ];
    };
  });
}
