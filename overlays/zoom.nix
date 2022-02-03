final: prev: {
  # Force Zoom to run on X11 for all the popups and everything
  zoom-us = prev.zoom-us.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [ prev.makeWrapper ];
    postFixup = old.postFixup or "" + ''
      wrapProgram $out/bin/zoom --set QT_QPA_PLATFORM xcb
    '';
  });
}
