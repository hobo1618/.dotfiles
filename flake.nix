{
  description = "Main Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:hobo1618/nixvim";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
        };
      };
#      homeConfigurations = {
 #       willh = home-manager.lib.homeManagerConfiguration {
  #        inherit pkgs;
   #       extraSpecialArgs = { inherit inputs; };
    #      modules = [ ./home.nix ];
     #   };
  #    };
    };
}
