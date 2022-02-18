final: prev: {
  avizo = prev.avizo.overrideAttrs (drv: {
    src = prev.fetchFromGitHub {
      owner = "misterdanb";
      repo = "avizo";
      rev = "d5c416aa7ac46660cd943f01ecfab6e29cb5e8c3";
      hash = "sha256-BRtdCOBFsKkJif/AlnF7N9ZDcmA+878M9lDQld+SAgo=";
    };
    patches = [ ];
  });
}
