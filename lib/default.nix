# 自定义 helper 的汇总入口（纯函数，不含模块系统的东西）。
# 注入给模块的是 modules/mylib.nix。
{ lib, pkgs }:
{
  nu = import ./nu.nix {
    inherit lib;
    package = pkgs.nushell;
  };
}
