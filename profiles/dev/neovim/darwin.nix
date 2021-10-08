{ lib, isDarwin, ... }:

lib.optionalAttrs isDarwin {
  homebrew.casks = [
    "vimr"
  ];
}
