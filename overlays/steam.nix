final: prev: {
  inherit (prev.master)
    steamPackages;

  pkgsi686Linux = prev.pkgsi686Linux.extend (_: _: {
    inherit (prev.master.pkgsi686Linux)
      steamPackages;
  });
}
