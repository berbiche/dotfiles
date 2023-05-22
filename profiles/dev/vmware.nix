{ config, lib, pkgs, ...}:

let
  cfg = config.profiles.dev.vmware;
in
{
  options.profiles.dev.vmware = {
    enable = lib.mkEnableOption "vmware installation and license management";
  };

  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "vmware-fusion"
    ];

    # Yeah, I didn't read the TOS, might be illegal
    # USE AT YOUR OWN RISK, I DO NOT ENDORSE OR PROVIDE ANY SUPPORT
    # OR GUIDANCE RELATED TO THE USE OF THE NEXT "HACK"
    launchd.agents.vmware-license-renewal = {
      script = ''
        /bin/rm /Library/Preferences/VMware\ Fusion/license*
      '';
      path = with pkgs; [ config.nix.package git gnutar gzip ];
      serviceConfig = rec {
        Label = "dev.normie.vmware-license-renewal";
        UserName = "root";
        ProcessType = "Background";
        # 29 days in seconds: 29 days * 24 hours * 60 minutes * 60 seconds
        StartInterval = 2505600; 
      };
    };
  };
}
