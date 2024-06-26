{ config, pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  configs = let
    files = builtins.readDir ./.;
    filtered = lib.filterAttrs (n: v: n != "default.nix" && v == "regular" && lib.hasSuffix ".nix" n);
  in map (p: ./. + "/${p}") (builtins.attrNames (filtered files));
in
{
  imports = configs;

  my.home.imports = [ ./home-manager ];

  fonts.packages = with pkgs; [
    anonymousPro
    source-code-pro
    nerdfonts
    emacs-all-the-icons-fonts
  ];

  services.emacs.enable = lib.mkIf isDarwin (lib.mkDefault true);

  environment.pathsToLink = [ "/share/zsh" "/share/fish" ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.fish.enable = true;
  # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  programs.fish.loginShellInit = let
    # This naive quoting is good enough in this case. There shouldn't be any
    # double quotes in the input string, and it needs to be double quoted in case
    # it contains a space (which is unlikely!)
    makeBinPath = pkg: lib.escapeShellArg "${lib.getBin pkg}/bin";
    profiles = lib.concatMapStringsSep " " makeBinPath config.environment.profiles;
  in lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''
    if test (uname) = Darwin
      fish_add_path --move --prepend --path (string split " " $NIX_PROFILES)[-1..1]/bin
      set fish_user_paths $fish_user_paths
    end
  '';

}
