{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    agenix.url = "github:ryantm/agenix";

    impermanence.url = "github:nix-community/impermanence";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    hyprland.url = "github:hyprwm/Hyprland";

    dotfiles = {
      url = "github:xBLACKICEx/my-dotfiles";
      flake = false;
    };

    fcitx5-theme-ayaya = {
      url = "github:witt-bit/fcitx5-theme-ayaya";
      flake = false;
    };

    fcitx5-themes-candlelight = {
      url = "github:thep0y/fcitx5-themes-candlelight";
      flake = false;
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-impulse.url = "github:xBLACKICEx/end-4-dots-hyprland-nixos";
    illogical-impulse.inputs.nixpkgs.follows = "nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dedsec-grub-theme = {
      url = "gitlab:VandalByte/dedsec-grub-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , agenix
    , disko
    , home-manager
    , nixpkgs
    , ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays { inherit inputs; };
      homeManagerModules = import ./modules/home-manager;
      nixosModules = import ./modules/nixos;

      nixosConfigurations = {
        # Laughing_Man = import ./hosts/Laughing_Man { inherit inputs outputs nixpkgs; };
        suzuha = import ./hosts/suzuha { inherit inputs outputs nixpkgs; };
      };
    };
}
