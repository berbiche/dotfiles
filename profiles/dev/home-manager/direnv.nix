{ ... }:

{
  # Load an `.envrc` file in the directory into the current shell
  # Extremely useful
  # See my patch in '$PROJECT_ROOT/overlays/direnv-disable-logging-exports.patch'
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    # I don't want direnv to be loaded in shitty `nix-shell`s
    enableBashIntegration = false;
    nix-direnv.enable = true;
    config = {
      global.disable_stdin = true;
      global.strict_env = true;
    };
  };

}
