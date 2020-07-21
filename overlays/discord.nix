final: prev:
{
  # Fix broken Discord nixos-unstable on 2020-06-16
  discord = prev.discord.overrideAttrs (old: rec {
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.libuuid ];
  });
}
