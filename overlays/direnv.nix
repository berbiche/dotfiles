final: prev:
{
  direnv = prev.direnv.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      ./direnv-disable-logging-exports.patch
    ];
  });
  nix-direnv = prev.nix-direnv.override { enableFlakes = true; };
}
