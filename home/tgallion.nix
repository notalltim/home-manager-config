{
  lib,
  pkgs,
  self,
  ...
}:
let
  inherit (lib.attrsets) attrValues;
  inherit (pkgs.lib) gpuWrapCheck;
in
{
  home = rec {
    stateVersion = "23.11";
    homeDirectory = "/home/${username}";
    username = "tgallion";
    enableDebugInfo = true;
    shellAliases = {
      reload-home-manager-config = "home-manager switch --flake ${builtins.toString ./.}";
    };

    packages = with pkgs; [
      (gpuWrapCheck kicad)
      (gpuWrapCheck freecad)
      jellyfin-media-player
      discord
      radeontop
      bitwarden
      audacity
      mprime
      openrgb-with-all-plugins
      (python3Full.withPackages (
        pkgs: with pkgs; [
          numpy
          scipy
          matplotlib
        ]
      ))
    ];
  };

  imports = attrValues self.outputs.homeModules;

  # For gdb debugging
  services.nixseparatedebuginfod.enable = true;

  services.ssh-agent.enable = true;

  # Common config expressed as basic modules
  baseline = {
    nixvim.enableAll = true;
    kitty.enableKeybind = true;
    packages.enable = true;
    home-manager.enable = true;
    gpu = {
      enable = true;
      enableVulkan = true;
    };
    # nix.enable = true; # TODO: this does not cover the case I want it does not control the nix version
    nixpkgs.enable = true;
    tools.enable = true;
    terminal.enable = true;
  };

  #TODO: this is not my favorite way to get overlays still torn over using self in common modules
  nixpkgs.overlays = [ self.overlays.default ];

  programs.git = {
    signing = {
      key = null;
    };
    userEmail = "timbama@gmail.com";
    userName = "Timothy Gallion";
  };
}
