{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
in
lib.mkIf isLinux {
  programs.mpv = {
    enable = true;
    scripts = [ pkgs.mpvScripts.mpris ];
  };

  xdg.configFile."mpv/mpv.conf".text = ''
    # Use hardware acceleration
    hwdec=vaapi
    vo=gpu
    hwdec-codecs=all
    gpu-context=wayland
    keep-open=yes
    profile=gpu-hq

    [profile-thinkpad]
    profile=gpu-hq

    [profile-make-my-gpu-scream]
    profile=gpu-hq
    scale=ewa_lanczossharp
    cscale=ewa_lanczossharp
    video-sync=display-resample
    interpolation
    tscale=oversample

    [onetime]
    keep-open=no

    [nodir]
    sub-auto=no
    audio-file-auto=no

    [image]
    profile=nodir
    mute=yes
    scale=ewa_lanczossharp
    background=0.1
    video-unscaled=yes
    title="''${?media-title:''${media-title}}''${!media-title:No file}"
    image-display-duration=inf
    loop-file=yes
    term-osd=force
    osc=no
    osd-level=1
    osd-bar=no
    osd-on-seek=no
    osd-scale-by-window=no


    #load-unsafe-playlists=yes

    [extension.webm]
    loop-file=inf

    [extension.mp4]
    loop-file=inf

    [extension.gif]
    interpolation=no

    # Ignore aspect ratio information for PNG and JPG, because it's universally bust
    [extension.png]
    video-aspect=no

    [extension.jpg]
    video-aspect=no

    [extension.jpeg]
    profile=extension.jpg
  '';

  xdg.configFile."mpv/input.conf".text = ''
    AXIS_DOWN add volume -2
    AXIS_UP   add volume 2

    MBTN_MID     cycle pause
    MBTN_BACK    add chapter -1
    MBTN_FORWARD add chapter 1

    r playlist-shuffle
  '';
}

