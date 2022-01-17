final: prev: {
  cinnamon = prev.cinnamon.overrideScope' (final': prev': {
    nemo = prev'.nemo.overrideAttrs (drv: {
      buildInputs = drv.buildInputs or [ ] ++ [ prev.glib-networking prev.dconf.lib ];
    });
  });
}
