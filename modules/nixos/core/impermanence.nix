{ config, lib, pkgs, ... }:
with lib;
{
  options.core.impermanence = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "是否启用 impermanence 模块";
    };

    persistence = mkOption {
      type = types.attrs;
      default = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/etc/shadow"
          "/etc/passwd"
          "/etc/group"
          "/etc/ssh"

          "/root"
          "/var"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
      description = "持久化目录和文件配置";
    };

    users = mkOption {
      type = types.attrs;
      default = { };
      description = "需要持久化的用户信息";
    };
  };

  config = mkIf config.core.impermanence.enable {
    environment.systemPackages = [ pkgs.ncdu ];
    systemd.services.nix-daemon = {
      environment = {
        # 指定临时文件的位置
        TMPDIR = "/var/cache/nix";
      };
      serviceConfig = {
        # 在 Nix Daemon 启动时自动创建 /var/cache/nix
        CacheDirectory = "nix";
      };
    };
    environment.variables.NIX_REMOTE = "daemon";

    environment.persistence."/persistent" = (config.core.impermanence.persistence // {
      users = config.core.impermanence.users;
    });
  };
}
