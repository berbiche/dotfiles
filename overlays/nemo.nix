final: prev: {
  cinnamon = prev.cinnamon.overrideScope' (final': prev': {
    nemo = prev'.nemo.overrideAttrs (drv: {
      buildInputs = drv.buildInputs or [ ] ++ [ prev.gnome.gvfs ];
    });
  });
}
