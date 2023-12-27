final: prev: let
  inherit (prev) haskellPackages lib fetchFromGitHub;
in {
  parthenon-hs = haskellPackages.mkDerivation rec {
    pname = "parthenon";
    version = "0.2.1";

    src = fetchFromGitHub {
      owner = "AntoineGagne";
      repo = "parthenon-hs";
      rev = "0.2.1";
      hash = "sha256-B7NMovyFMGmp2OEOsA3KcbzCwfE/p/fD+zMfC6952uE=";
    };

    isExecutable = true;

    executableHaskellDepends = with haskellPackages; [
      aeson optparse-applicative megaparsec parser-combinators
      #containers_0_7 bytestring_0_12_0_2 text
    ];

    testHaskellDepends = with haskellPackages; [
      hspec
    ];

    description = "Tool to convert Athena terms to JSON";
    maintainers = [ lib.maintainers.berbiche ];
    license = lib.licenses.bsd3;
    homepage = src.meta.homepage;
  };
}
