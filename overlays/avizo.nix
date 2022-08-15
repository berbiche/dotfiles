final: prev: {
  avizo = prev.avizo.overrideAttrs (drv: {
    src = prev.fetchFromGitHub {
      owner = "misterdanb";
      repo = "avizo";
      # berbiche:basic-x11-support
      rev = "67af5fd55279c25546d79cebdb4cb73440093082";
      hash = "sha256-bZE9uTAaKUFP3zw6pJB8xpZjN00vM7lntn5zG3+2CYc=";
    };
    patches = [ ];
  });
}
