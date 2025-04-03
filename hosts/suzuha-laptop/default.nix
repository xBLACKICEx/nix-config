{ nixpkgs, dedsec-grub-theme, home-manager, inputs, anyrun, outputs, pkgs, ... }:

nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs outputs anyrun pkgs; };
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hypr

    inputs.impermanence.nixosModules.impermanence
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
