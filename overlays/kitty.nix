final: prev: {
  # The package always fails to build on Darwin,
  # so just disable it and use the cask instead
  kitty = prev.runCommandLocal "dummy" { } "mkdir -p $out";
}
