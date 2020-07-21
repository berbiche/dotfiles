final: prev: let
  # Yeah, this is really hacky since we are not injecting our overlays in nixpkgs-master
  krunner = (import prev.inputs.master { }).kdeFrameworks.krunner;
in
{
  kdeFrameworks = prev.kdeFrameworks // { inherit krunner; };
}
