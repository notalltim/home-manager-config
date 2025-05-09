{ inputs, ... }:
{
  flake.homeModules = {
    nixvim = import ./home/nixvim;
    terminal = import ./home/terminal;
    tool = import ./home/tools;
    services = import ./home/services;
    packages = import ./home/packages.nix;
    home-manager = import ./home/home-manager.nix;
    gpu = import ./home/gpu;
    nix = import ./home/nix.nix;
    nixpkgs = import ./home/nixpkgs;
    nixvimUpstream = inputs.nixvim.homeManagerModules.nixvim;
    non-nixos = import ./home/non-nixos.nix;
  };
}
