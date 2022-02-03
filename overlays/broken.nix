final: prev: {
  # A Python dependency is broken
  pdfarranger = prev.runCommandLocal "broken-pdfarranger" { } ''mkdir "$out"'';
}
