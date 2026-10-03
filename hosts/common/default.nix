{ lib, ... }: {
  imports = [
    ./nix.nix
    ./pkgs.nix
    # 注入模块参数 `mylib`。
    ../../modules/mylib.nix
  ];

  security.sudo.enable = lib.mkForce false;

  security.sudo-rs = {
    enable = true;

    wheelNeedsPassword = true;
  };
}
