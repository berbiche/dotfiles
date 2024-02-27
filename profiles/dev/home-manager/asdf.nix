{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.dev.asdf;
in
{

  options.profiles.dev.asdf.enable = lib.mkEnableOption "asdf";
  options.profiles.dev.asdf.package = lib.mkPackageOption pkgs "asdf-vm" {};

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    programs.fish.interactiveShellInit = ''
      begin
        set -l path_asdf_vm ${lib.escapeShellArg cfg.package}/share/asdf-vm
        set -x ASDF_DIR $path_asdf_vm
        source "$path_asdf_vm"/asdf.fish
        if set -l index (contains -i "$path_asdf_vm"/bin $fish_user_paths)
          set --erase --universal fish_user_paths[$index]
        end
        if set -l index (contains -i "$path_asdf_vm"/bin $PATH)
          set --erase PATH[$index]
        end
      end
    '';
  };
}
