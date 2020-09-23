final: prev:
let
  src = prev.fetchurl {
    url = "https://github.com/felberj/gotools/releases/download/v0.1.2/ghidra_9.1.2_PUBLIC_20200521_gotools.zip";
    sha256 = "o29WrAGgNNKKiiT/+VJwlE8bDfBZghoQhaLsw8kEONo=";
  };
in
{
  ghidra-bin-with-go = prev.ghidra-bin.overrideAttrs(old: {
    installPhase = old.installPhase or "" + ''
      echo "Installing extension"
      cp ${src} $out/lib/ghidra/Extensions/gotools.zip
    '';
  });
}
