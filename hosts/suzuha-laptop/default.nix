{ nixpkgs, dedsec-grub-theme, home-manager, inputs, outputs, pkgs, ... }:

nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs outputs; };
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    dedsec-grub-theme.nixosModule
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.michiha = ../../home/michiha.nix;
      home-manager.extraSpecialArgs = { inherit pkgs inputs outputs; };
    }
  ];
}