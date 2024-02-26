{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS 官方软件源，这里使用 nixos-23.11 分支import ./laptop.nix inputs;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # helix editor, use the master branch
    helix.url = "github:helix-editor/helix/master";

    # ixpkgs.config.allowUnfree = true;
    dedsec-grub-theme = {
      url = "gitlab:VandalByte/dedsec-grub-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  # 这里的 `self` 是个特殊参数，它指向 `outputs` 函数返回的 attribute set 自身，即自引用
  outputs = { self, nixpkgs, dedsec-grub-theme, home-manager, ... }@inputs: {

    nixosConfigurations = {
      "suzuha" = import ./hosts/suzuha-laptop inputs;

    };
  };
}
