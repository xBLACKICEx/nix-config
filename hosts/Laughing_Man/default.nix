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
    ./configuration.nix # host-specific configuration

    # custom configuration modules

    inputs.dedsec-grub-theme.nixosModule
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence

    # home-manager
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.h4x0r_k4n3da = ../../home/h4x0r_k4n3da;
      home-manager.extraSpecialArgs = { inherit inputs outputs; };
    }
  ];
}
