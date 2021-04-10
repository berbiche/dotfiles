{ ... }:

{
  my.home = { config, lib, pkgs, ... }: {
    programs.zsh.initExtra = ". ${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
    home.packages = [ pkgs.nix-index ];
    # Disabled as of 2021-04-02 because switching Home Manager profiles
    # uses a Systemd service and it doesn't emit any output during the switch by nixos-rebuild
    # home.activation.runNixIndex = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [ -d "${config.xdg.cacheHome}" ]; then
    #     echo "Performing initial caching of nix-index"
    #     $DRY_RUN_CMD nix-index
    #   fi
    # '';
  };
}

