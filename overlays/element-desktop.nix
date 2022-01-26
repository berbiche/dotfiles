final: prev: {
  element-desktop = final.master.element-desktop.override {
    # Broken with current Electron versions
    # See https://github.com/NixOS/nixpkgs/issues/156352,
    # https://github.com/electron/electron/issues/32487,
    # https://github.com/vector-im/element-web/issues/20467,
    # https://github.com/electron/electron/pull/32603
    useWayland = final.lib.versionAtLeast final.electron.version "16.0.7";
  };
}
