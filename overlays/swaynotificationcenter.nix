final: prev: {
  swaynotificationcenter = prev.swaynotificationcenter.overrideAttrs (drv: {
    version = "unstable-2022-05-17";
    src = prev.fetchFromGitHub {
      owner = "ErikReider";
      repo = "SwayNotificationCenter";
      rev = "a9c7af237102303908a4392da0dc8e86db60d9d4";
      hash = "sha256-LKt/iB/mNAe0CBuw/0L8iBvnWkUnLzBhGQXA1WgM9SQ=";
    };
  });
}
