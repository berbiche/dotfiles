final: prev: {
  nixpkgs-wayland = prev.nixpkgs-wayland // {
    waybar = prev.nixpkgs-wayland.waybar.overrideAttrs (drv: {
      patches = drv.patches or [ ] ++ [
        (prev.fetchpatch {
          name = "fix-inability-to-set-bar-width-with-gtklayershell.patch";
          url = "https://github.com/berbiche/WayBar/commit/98646643f19784042f9d9384828867254d5b8ea1.patch";
          sha256 = "sha256-pDw2xkM2uWDUHxEMI/sLfKOSALL/s3hANVqV/FaPJg0=";
        })
      ];
      # src = prev.fetchFromGitHub {
      #   owner = "berbiche";
      #   repo = "Waybar";
      #   # fix/gtk-layer-shell-anchors
      #   rev = "66ebb7c07b3918d8e66ab10aa7c8ecba6d98aac7";
      #   hash = "sha256-u0S1i7E73evLNWhzZ2ncrFTZuH8re9G5woc3IMOLEOo=";
      # };
    });
  };
}
