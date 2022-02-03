final: prev: {
  pantheon = prev.pantheon.overrideScope' (_: prev': {
    elementary-files = prev'.elementary-files.overrideAttrs (drv: {
      postPatch = drv.postPatch or "" + ''
        sed -i 's,"io.elementary.files -t","'"$out"'/bin/io.elementary.files -t",' pantheon-files-daemon/FileManager1.vala
      '';
    });
  });
}
