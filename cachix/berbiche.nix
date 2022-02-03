
{
  nix = {
    settings.substituters = [
      "https://berbiche.cachix.org"
    ];
    settings.trusted-public-keys = [
      "berbiche.cachix.org-1:lrgfrUAjlfn36CIwyxt1u7/RddiK4n1tzf3+kMNI2uw="
    ];
  };
}
