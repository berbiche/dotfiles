final: prev:
{
  git = prev.git.override { withLibSecret = true; };
}
