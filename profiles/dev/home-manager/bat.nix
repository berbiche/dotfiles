{ config, lib, pkgs, ... }:

{
  programs.bat.enable = true;

  programs.bat.config = {
    # Set the theme to "TwoDark"
    theme = "TwoDark";

    # Never wrap, the terminal handles it
    wrap = "never";

    # Show line numbers, Git modifications and file header (but no grid)
    style="numbers,changes,header";

    # Use italic text on the terminal (not supported on all terminals)
    italic-text = "always";

    # Add mouse scrolling support in less (does not work with older
    # versions of "less")
    pager = "less --quit-if-one-screen --RAW-CONTROl-CHARS";

    map-syntax = [
      # Use C++ syntax (instead of C) for .h header files
      "h:cpp"
      # Use "gitignore" highlighting for ".ignore" files
      ".ignore:.gitignore"
      # Use JSON highlighting for flake.lock
      "flake.lock:JSON"
    ];
  };
}
