final: prev:

with prev.lib;

let
  version = "26.0.0-dmabuf";
  versionFlag = "-DOBS_VERSION_OVERRIDE";
in
{
  obs-studio = prev.obs-studio.overrideAttrs (old:
    let
      cmakeFlags = old.cmakeFlags or [ ];
      hasFixedVersion = any (hasPrefix versionFlag) cmakeFlags;
    in optionalAttrs (!hasFixedVersion) {
      cmakeFlags = cmakeFlags ++ [ "${versionFlag}=${version}" ];
    });
}
