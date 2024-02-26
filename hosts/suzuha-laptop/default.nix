{ nixpkgs, dedsec-grub-theme, home-manager, ... }@inputs:

nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    dedsec-grub-theme.nixosModule
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      # 这里的 ryan 也得替换成你的用户名
      # 这里的 import 函数在前面 Nix 语法中介绍过了，不再赘述
      home-manager.users.poporo = import ../../home;

      # 使用 home-manager.extraSpecialArgs 自定义传递给 ./home.nix 的参数
      # 取消注释下面这一行，就可以在 home.nix 中使用 flake 的所有 inputs 参数了
      # home-manager.extraSpecialArgs = inputs;
    }
  ];
}
