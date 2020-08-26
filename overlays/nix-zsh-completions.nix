final: prev:
{
  nix-zsh-completions = prev.nix-zsh-completions.overrideAttrs (_: {
    src = prev.fetchFromGitHub {
      owner = "ma27";
      repo = "nix-zsh-completions";
      rev = "c63f5627b8d1f8ea9c9e71b558088ae74934feab";
      sha256 = "1vc3h5l665r2ynk7bcijlaivnk4rq0nx3ff812pcahmczy8rd4la";
    };
  });
}