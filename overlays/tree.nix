final: prev: {
  tree = prev.runCommandLocal "tree" { } "mkdir -p $out";
}
