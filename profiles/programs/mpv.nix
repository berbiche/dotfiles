{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
in
{
  programs.mpv = {
    enable = true;

    scripts = lib.mkIf isLinux [ pkgs.mpvScripts.mpris ];

    defaultProfiles = lib.mkDefault [ "gpu-hq" "interpolation" ];

    config = {
      # Use hardware acceleration
      hwdec = "vaapi";
      vo = "gpu";
      hwdec-codecs = "all";
      gpu-context = "wayland";
      keep-open = true;

      script-opts="ytdl_hook-ytdl_path=${pkgs.yt-dlp}/bin/yt-dlp";
    };

    bindings = {
      "AXIS_DOWN" = "add volume -2";
      "AXIS_UP" = "add volume 2";

      "MBTN_MID" = "cycle pause";
      "MBTN_BACK" = "add chapter -1";
      "MBTN_FORWARD" = "add chapter 1";

      "r" = "playlist-shuffle";
    };

    profiles = {
      interpolation = {
        interpolation = true;
        tscale = "box";
        tscale-window = "quadric";
        tscale-clamp = 0.0;
        tscale-radius = 1.025;
        video-sync = "display-resample";
        blend-subtitles = "video";
      };

      profile-thinkpad.profile = "gpu-hq";

      profile-make-my-gpu-scream = {
        profile = "gpu-hq";
        interpolation = true;
        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        video-sync = "display-resample";
        tscale = "oversample";
      };

      onetime = {
        keep-open = false;
      };

      nodir = {
        sub-auto = false;
        audio-file-auto = false;
      };

      image = {
        profile = "nodir";
        mute = true;
        scale = "ewa_lanczossharp";
        background = 0.1;
        video-unscaled = true;
        title="\${?media-title:\${media-title}}\${!media-title:No file}";
        image-display-duration = "inf";
        loop-file = true;
        term-osd = "force";
        osc = false;
        osd-level = 1;
        osd-bar = false;
        osd-on-seek = false;
        osd-scale-by-window = false;
      };
      "extension.webm" = {
        loop-file = "inf";
      };
      "extension.mp4" = {
        loop-file = "inf";
      };
      "extension.gif" = {
        interpolation = "no";
      };
      "extension.png" = {
        video-aspect = "no";
      };
      "extension.jpg" = {
        video-aspect = "no";
      };
      "extension.jpeg" = {
        profile = "extension.jpg";
      };
    };
  };
}

