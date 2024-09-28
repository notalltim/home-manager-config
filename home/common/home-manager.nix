{ lib, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.baseline.home-manager;
in
{
  options = {
    baseline.home-manager.enable = mkEnableOption "Enable baseline home-manager configuration";
  };

  config = mkIf cfg.enable {
    programs.home-manager.enable = true;
    # For non nixos hosts to declare where systemctl is
    systemd.user = {
      startServices = true;
      systemctlPath = "/usr/bin/systemctl";
    };
    # TODO: this is not great for nixos hosts
    targets.genericLinux.enable = false;

    xdg.enable = true;

    news.display = "silent";
    manual = {
      html.enable = true;
      json.enable = true;
      manpages.enable = true;
    };
  };
}
