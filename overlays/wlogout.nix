final: prev:

{
  wlogout = prev.wlogout.overrideAttrs (old: {
    buildInputs = old.buildInputs or [ ] ++ [ prev.gtk-layer-shell ];
  });
}
