final: prev: {
  avizo = prev.avizo.overrideAttrs (drv: {
    src = prev.fetchFromGitHub {
      owner = "misterdanb";
      repo = "avizo";
      # berbiche:basic-x11-support
      rev = "61d220b6ad48f77cffe7bca0dde8605596583516";
      hash = "sha256-+el6wqBIKKeIYI1OuVyod4vt676Hh6eC5tGAuY+6FrY=";
    };
    patches = [ ];
  });
}
