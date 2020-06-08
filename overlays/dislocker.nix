self: super:
let
  revision = "339733f0bda09fd84ae20d9c1b4e7c501ca203e5";
  sha256 = "18170ibq1nddisk717l18ggd3cr5f7ilj3ax5rzgj0ywg7m1l7wg";
in
{
  dislocker = super.dislocker.overrideAttrs (old: rec {
    name = "dislocker-${version}";
    version = "${old.version}-${revision}";
    src = super.fetchFromGitHub {
      owner = "aorimn";
      repo = "dislocker";
      rev = revision;
      sha256 = sha256;
    };
  });
}
