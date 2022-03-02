final: prev: let
  version = "0.0.134";
in {
  discord-canary = prev.discord-canary.overrideAttrs (drv: {
    inherit version;
    src =
      if prev.stdenv.hostPlatform.isLinux then
        prev.fetchurl {
          url = "https://dl-canary.discordapp.net/apps/linux/${version}/discord-canary-${version}.tar.gz";
          sha256 = "sha256-HyJa6lGcKMPKWffO/pnNcn8fDTJj6O4J8Y5RA23a1kM=";
        }
      else null;
  });
}
