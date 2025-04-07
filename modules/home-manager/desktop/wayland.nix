{ config, pkgs, lib, ... }: {
  options.desktop.wayland.enable = lib.mkEnableOption "Enable wayland packages";

  config = lib.mkIf config.desktop.wayland.enable {
    home.packages = with pkgs; [
      # 用于截取屏幕截图的工具
      grim
      # Qt 6 Wayland 支持，允许 Qt 应用程序在 Wayland 合成器上运行
      qt6.qtwayland
      # 用于选择屏幕区域的工具，通常与 grim 一起使用
      slurp
      # 通过网络转发 Wayland 显示的工具
      waypipe
      # 用于录制 Wayland 合成器会话的工具
      wf-recorder
      # 用于镜像 Wayland 窗口或整个屏幕的工具
      wl-mirror
      # 用于访问和修改 Wayland 剪贴板的工具
      wl-clipboard
      # Wayland 注销/关机/重启菜单
      wlogout
      # 用于向 Wayland 窗口发送按键和文本的工具
      wtype
      # 用于自动化 Wayland 桌面任务的工具，例如移动鼠标和模拟按键
      ydotool
    ];
  };
}
