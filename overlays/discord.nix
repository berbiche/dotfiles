final: prev:
{
  # https://github.com/NixOS/nixpkgs/issues/93955
  discord = prev.discord.override { nss = prev.nss_3_44; };
}
