{ lib, ... }:

{
  # Declare these options as stubs since they are not declared on Linux but used on Darwin
  options.homebrew = lib.mkSinkUndeclaredOptions { };
  options.launchd = lib.mkSinkUndeclaredOptions { };
}
