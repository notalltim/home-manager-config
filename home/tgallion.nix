{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (pkgs.lib) gpuWrapCheck;
in {
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
    ];
  };

  imports = mapAttrsToList (_: module: module) (import ./.);

  # For gdb debugging
  services.nixseparatedebuginfod.enable = true;

  services.ssh-agent.enable = true;

  # Support kitty on non nixos system
  programs.kitty.package = gpuWrapCheck pkgs.kitty;

  # Common config expressed as basic modules
  baseline = {
    nixvim.enableAll = true;
    kitty.enableKeybind = true;
    packages.enable = true;
    git.enable = true;
    gdb.enable = true;
    home-manager.enable = true;
    gpu.enable = true;
    nix.enable = true; #TODO: this does not cover the case I want it does not control the nix version
    nixpkgs.enable = true;
  };

  programs.git = {
    signing = {
      key = "5A2DAA31F5457F29";
    };
    userEmail = "timbama@gmail.com";
    userName = "Timothy Gallion";
  };
}
