{ ... }: {
  # Core persistence
  core.impermanence = {
    enable = true;
    persistence = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos/nix-config"
        "/etc/agenix"

        "/var/log"
        "/var/lib/nixos" # 通用 NixOS 本机状态，建议
        "/var/lib/bluetooth" # 蓝牙配对信息
        "/var/lib/docker" # Docker 镜像、容器、卷
        "/var/lib/libvirt" # 虚拟机状态
        "/var/lib/syncthing" # Syncthing 设备身份和数据库
        "/var/lib/AccountsService" # 登录管理器用户头像/会话偏好，桌面按需

        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
        {
          directory = "/srv/sync/shared";
          user = "syncthing";
          group = "syncthing-shared";
          mode = "2770";
        }
        {
          directory = "/srv/Shared";
          group = "shared";
          mode = "2770";
        }
        {
          directory = "/configs";
          group = "configs";
          mode = "2770";
        }

      ];
      files = [
        "/etc/machine-id"
      ];
    };
    users = {
      beatrice = {
        directories = [
          "Desktop"
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Projects"
          "Videos"

          ".codex"
          ".cache/codex-desktop"
          ".cache/codex-runtimes"
          ".config"

          # vscode
          ".vscode"
          ".vscode-shared"
          ".vscode-insiders"

          # browsers
          ".mozilla"
          ".zen"

          ".local/share"
          ".local/state"

          ".ssh"
        ];
      };
    };
  };
}
