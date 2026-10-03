# 把 lib/ 注入成模块参数 `mylib`，NixOS 与 home-manager 共用本文件。
# 用 _module.args 而不是 specialArgs：这里需要 pkgs，而 specialArgs
# 在 nixosSystem 求值前就得算出来。
{ lib, pkgs, ... }:
{
  _module.args.mylib = import ../lib { inherit lib pkgs; };
}
