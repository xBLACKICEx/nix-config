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
    inputs.agenix.nixosModules.default
    ./configuration.nix # host-specific configuration

    {
      environment.systemPackages = [
        inputs.agenix.packages.${system}.default
      ];
    }

    # custom configuration modules
    # outputs.nixosModules.secureboot

    outputs.nixosModules.dedsecGrubTheme
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence

    # home-manager
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.backupFileExtension = "bkp";

      home-manager.users.michiha = ./michiha;

      home-manager.extraSpecialArgs = { inherit inputs outputs; };
    }
  ];
}
