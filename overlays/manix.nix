final: prev: {
  manix = prev.manix.overrideAttrs (drv: {
    postPatch = drv.postPatch or "" + ''
      sed -i 's|<home-manager/doc>|<home-manager/docs>|' src/options_docsource.rs
    '';
  });
}
