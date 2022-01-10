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

  profiles.dev.wakatime.enable = lib.mkDefault true;

  fonts.fonts = with pkgs; [
    anonymousPro
    source-code-pro
    nerdfonts
    emacs-all-the-icons-fonts
  ];

  services.emacs.enable = lib.mkIf isDarwin true;

  environment.pathsToLink = [ "/share/zsh" "/share/fish" ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };
}
