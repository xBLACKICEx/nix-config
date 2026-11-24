{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;

  # Plasma Login can keep a store-pinned Steam session launcher until its
  # daemon restarts. That launcher resolves `gamescope` through the login PATH,
  # so a user-only wrapper also updates already-cached session launchers.
  gamescopeSession = pkgs.writeShellApplication {
    name = "gamescope";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      # Steam hides output-mode controls without a writable mode-save path.
      # Gamescope reads this same file when restoring the display mode.
      export GAMESCOPE_MODE_SAVE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/modes.cfg"
      mkdir -p "$(dirname "$GAMESCOPE_MODE_SAVE_FILE")"
      touch "$GAMESCOPE_MODE_SAVE_FILE"
      export ENABLE_GAMESCOPE_WSI=1
      export DXVK_HDR=1
      exec ${pkgs.gamescope}/bin/gamescope --hdr-enabled "$@"
    '';
  };
in
{
  options.gaming = {
    enable = lib.mkEnableOption "Wine/Windows 兼容层与游戏工具";

    steamLibrary = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/games-lib/steam/steamapps";
      description = ''
        当前用户的 Steam 默认游戏库（steamapps 目录）。设为 null 时保留
        Steam 默认的 ~/.local/share/Steam/steamapps。
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Windows 软件 / 游戏兼容层
      wineWow64Packages.stable # 64 位 + WoW64 的 Wine
      winetricks # 给 Wine prefix 安装运行库、字体和组件
      bottles # 图形化 Wine prefix 管理
      protontricks # 给 Proton 游戏运行 winetricks
      umu-launcher # 在 Steam 之外用 Proton 启动 Windows 游戏
      dxvk # Direct3D 9/10/11 → Vulkan
      vkd3d-proton # Direct3D 12 → Vulkan

      # 游戏工具
      heroic # Epic / GOG / Amazon 启动器
      lutris # 统一的 Linux 游戏启动器
      mangohud # 性能叠加层
      goverlay # MangoHud 图形化配置
      gamemode # 游戏时临时调整 CPU 调度
      gamescopeSession # 带 HDR / 模式保存的 Gamescope 包装器
      protonup-qt # 安装和管理 Proton-GE / Wine-GE
      vkbasalt # Vulkan 后处理（CAS、SMAA 等）
      jstest-gtk # 检查手柄轴和按键映射
    ];

    # 把 Steam 默认库放到游戏子卷；账号设置和 userdata 仍留在各自家目录。
    home.file.".local/share/Steam/steamapps" = lib.mkIf (cfg.steamLibrary != null) {
      source = config.lib.file.mkOutOfStoreSymlink cfg.steamLibrary;
    };
  };
}
