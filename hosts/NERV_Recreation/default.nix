{ nixpkgs, inputs, outputs }:
let
  system = "x86_64-linux";
in
nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs outputs;
  };

  modules = [
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

      home-manager.users.michiha = ../../home/michiha;
      home-manager.extraSpecialArgs = { inherit inputs outputs; };
    }
  ];
}
