final: prev: {
  # My school uses an old Java Applet to register for classes and related tasks.
  # It's ugly and annoying to use.
  # See: https://www.etsmtl.ca/en/studies/ChemiNot
  cheminot-ets = prev.makeDesktopItem {
    name = "ChemiNot";
    exec = prev.writeShellScript "cheminot" ''
      ${prev.icedtea_web}/bin/javaws <(curl 'https://cheminotjws.etsmtl.ca/ChemiNot.jnlp')
    '';
    comment = "ChemiNot is an integrated consultation and registration system for ÉTS students";
    desktopName = "ChemiNot";
  };
}
