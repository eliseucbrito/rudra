{
  description = "Rudra flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # zen-browser.url = "github:MarceColl/zen-browser-flake";
    # update of Out/2024
    zen-browser.url = "github:eliseucbrito/zen-browser-flake";
    nixvim.url = "github:daniloraisi/nixvim";

    hyprlux = {
      url = "github:amadejkastelic/Hyprlux";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/default/configuration.nix
        inputs.stylix.nixosModules.stylix
        inputs.home-manager.nixosModules.default
	inputs.hyprlux.nixosModules.default
        ({ pkgs, ... }: {
          environment.systemPackages = [
          ];
        })
      ];
    };
  };
}
