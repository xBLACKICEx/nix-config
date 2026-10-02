{ nixpkgs, inputs, outputs }:
let
  hostPlatform = "x86_64-linux";
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs outputs;
  };

  modules = [
    { nixpkgs.hostPlatform = hostPlatform; }
    ../common
    ./configuration.nix

    outputs.nixosModules.dedsecGrubTheme
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bkp";

      home-manager.users.beatrice = ../../home/beatrice;
      home-manager.extraSpecialArgs = { inherit inputs outputs; };
    }
  ];
}
