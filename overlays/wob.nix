final: prev:
{
  wob = prev.wob.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      ./print-invalid-input-buffer-and-continue.patch
    ];
    # src = prev.fetchFromGitHub {
    #   owner = "francma";
    #   repo = "wob";
    #   rev = "e4c6d817855e9aa8892162da12a087e6abd6a7de";
    #   hash = "sha256-zbLvz/usyhfn9+oSNYSGj8dfPvkVQMnC0lzuBX0EmSU=";
    # };
  });
}
