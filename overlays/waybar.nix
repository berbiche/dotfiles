final: prev: {
  nixpkgs-wayland = prev.nixpkgs-wayland // {
    waybar = prev.nixpkgs-wayland.waybar.overrideAttrs (drv: {
      src = prev.fetchFromGitHub {
        owner = "berbiche";
        repo = "Waybar";
        rev = "0.9.9";
        hash = "sha256-LLhf6bkNTYz7MkrXzyccB7ofsif3cDsBbIs8Z+2IAwg=";
      };
    });
  };
}
