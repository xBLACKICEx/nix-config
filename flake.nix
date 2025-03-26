{
  description = "nixos flake config";

  inputs = {
    # NixOS 官方软件源，这里使用 nixos-unstable 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # ixpkgs.config.allowUnfree = true;
    dedsec-grub-theme = {
      url = "gitlab:VandalByte/dedsec-grub-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 这里的 `self` 是个特殊参数，它指向 `outputs` 函数返回的 attribute set 自身，即自引用
  outputs = { self, nixpkgs, dedsec-grub-theme, home-manager, zen-browser, anyrun, ... }@inputs:
    let
      overlays = [
        # 添加自定义包
        self.overlays.additions
        # 修改现有包
        self.overlays.modifications
      ];

      inherit (self) outputs;
      system = "x86_64-linux"; # System architecture
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true; # Allow proprietary software
      };
    in
    {
      homeManagerModules = import ./modules/home;
      overlays = import ./overlays;
      nixosConfigurations = {
        "suzuha" = import ./hosts/suzuha-laptop { inherit nixpkgs dedsec-grub-theme home-manager inputs outputs anyrun pkgs; };
      };
    };
}
