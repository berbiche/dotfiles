final: prev:
{
  direnv = prev.direnv.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      ./direnv-disable-logging-exports.patch
    ];
  });
}
