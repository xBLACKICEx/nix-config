{ config, lib, ... }:
{
  # 由 NixOS core.impermanence 自动导入；root 激活脚本负责校正权限。
  options.impermanence.enforcePermissions = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "自动校正 home.persistence 的目录和文件权限；需要 NixOS core.impermanence 集成。";
  };

  # 封装 home.persistence，允许文件声明 user/group/mode。
  options.impermanence.persistence = lib.mkOption {
    type = lib.types.attrsOf lib.types.attrs;
    default = { };
    description = "Home Manager 持久化声明；转发到 home.persistence，文件可额外设置 user/group/mode。";
  };

  config.home.persistence = lib.mapAttrs (_: scope: scope // lib.optionalAttrs (scope ? files) {
    files = map (file: if lib.isAttrs file then
      builtins.removeAttrs file [ "user" "group" "mode" ] else file) scope.files;
  }) config.impermanence.persistence;
}
