{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix = {
      url = "github:NixOS/nix?ref=2.24-maintenance";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Input sources for internal packages
    gcc-python-pretty-printers = {
      url = "github:gcc-mirror/gcc?ref=releases/gcc-13.3.0&shallow=1";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = import ./overlays {
        inherit self;
        lib = nixpkgs.lib;
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlays.default ];
      };
    in
    {
      nixosConfigurations.xps15 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.tgallion = import ./home/tgallion.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            home-manager.extraSpecialArgs = {
              inherit self;
            };
            # arguments to home.nix
          }
          nixos-hardware.nixosModules.dell-xps-15-9570
        ];
        specialArgs = {
          inherit self;
        };
      };

      inherit overlays;

      homeConfigurations.${"tgallion"} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/tgallion.nix ];
        extraSpecialArgs = {
          inherit self;
        };
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      legacyPackages.${system} = pkgs;

      homeModules = (import ./home) self;
    };
}
