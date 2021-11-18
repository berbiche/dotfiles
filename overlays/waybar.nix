final: prev: {
  nixpkgs-wayland = prev.nixpkgs-wayland // {
    waybar = prev.nixpkgs-wayland.waybar.overrideAttrs (drv: {
      src = prev.fetchFromGitHub {
        owner = "berbiche";
        repo = "Waybar";
        # fix/gtk-layer-shell-anchors
        rev = "66ebb7c07b3918d8e66ab10aa7c8ecba6d98aac7";
        hash = "sha256-u0S1i7E73evLNWhzZ2ncrFTZuH8re9G5woc3IMOLEOo=";
      };
    });
  };
}
