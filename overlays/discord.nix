self: super:
{
  # Fix broken Discord nixos-unstable on 2020-06-16
  discord = super.discord.overrideAttrs (old: rec {
    nativeBuildInputs = old.nativeBuildInputs ++ [ super.libuuid ];
  });
}
