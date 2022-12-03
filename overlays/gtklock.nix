final: prev:
{
  gtklock = prev.gtklock.overrideAttrs(drv: {
    version = "2022-12-01";

    src = prev.fetchFromGitHub {
      owner = "jovanlanik";
      repo = drv.pname;
      rev = "1c2a5d36077b9aa92a50ba8483892fb2393be8b4";
      hash = "sha256-wz23Fg0L3FYaef6fqLhGBTpnk3PDfqW3GtZLp6Tz1cE=";
    };

    nativeBuildInputs = drv.nativeBuildInputs ++ [
      prev.wrapGAppsHook
    ];
  });
}
