{ pkgs, inputs, outputs, ... }:
let
  hypr = inputs.hyprland.packages.${pkgs.system};
in
{
  imports = [
    ../common
   
    outputs.homeManagerModules.fcitx5
    outputs.homeManagerModules.desktop
   
    inputs.illogical-impulse.homeManagerModules.default
  ];

  home = {
    # 注意修改这里的用户名与用户目录
    # username = username;
    # homeDirectory = "/home/beatrice";

    packages = with pkgs; [
      # 一些常用的软件
      inputs.zen-browser.packages."${system}".default
      # 一些常用的软件
      inputs.zen-browser.packages."${system}".default

      anytype

      # 终端文件管理器
      yazi

      # 常用工具
      ripgrep # 递归搜索目录中的正则表达式模式
      fd # find 的替代品
      jq # 轻量级且灵活的命令行 JSON 处理器
      yq-go # YAML 处理器 https://github.com/mikefarah/yq
      lsd
      vscode

      # 网络工具
      mtr # 网络诊断工具
      iperf3
      dnsutils # `dig` + `nslookup`
      ldns # `dig` 的替代品，提供 `drill` 命令
      aria2 # 轻量级多协议 & 多源命令行下载工具
      socat # openbsd-netcat 的替代品
      nmap # 用于网络发现和安全审计的实用程序
      ipcalc # IPv4/v6 地址计算器

      # 其他工具
      cowsay
      file
      which
      gnused
      gnutar
      gawk
      zstd
      gnupg
      keepassxc
      kikoplay


      # editors
      helix
      helix-gpt

      # 效率工具
      hugo # 静态站点生成器
      glow # 终端中的 Markdown 预览器

      btop # htop/nmon 的替代品
      iotop # IO 监控
      iftop # 网络监控

      # 系统调用监控
      strace # 系统调用监控
      ltrace # 库调用监控
      lsof # 列出打开的文件

      warp-terminal

      # 系统工具
      sysstat
      lm_sensors # 用于 `sensors` 命令
      ethtool
      pciutils # lspci
      usbutils # lsusb
      brightnessctl # 控制屏幕亮度，用于 Hyprland

      # 聊天工具
      telegram-desktop
      element-desktop
      discord
    ];

    # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
    # file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

    # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
    # file.".config/i3/scripts" = {
    #   source = ./scripts;
    #   recursive = true;   # 递归整个文件夹
    #   executable = true;  # 将其中所有文件添加「执行」权限
    # };

    # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
    # file.".xxx".text = ''
    #     xxx
    # '';

    stateVersion = "25.05";
  };

### BEGIN -- CUSTOM HOME MANAGER MODULES CONFIGURATION -- BEGIN ###
  # desktop.hypr.enable = true;
 
  illogical-impulse = {
    # Enable Dotfiles
    enable = true;
    hyprland = {
      # Monitor preference
      monitor = [ ",preferred,auto,1" ];
      # Use customize hyprland packages
      package = hypr.hyprland;
      xdgPortalPackage = hypr.xdg-desktop-portal-hyprland;
      # Set NIXOS_OZONE_WL=1
      ozoneWayland.enable = true;
    };
    theme = {
      # Customize Cursors,
      # the following config is the default config
      # if you don't set.
      cursor = {
        package = pkgs.bibata-cursors;
        theme = "Bibata-Modern-Ice";
      };
    };
    # Use custom ags package, the following package is the default.
    # agsPackage = ags.packages.${pkgs.system}.default.override {
    #   extraPackages = with pkgs; [ 
    #     gtksourceview
    #     gtksourceview4
    #     webkitgtk
    #     webp-pixbuf-loader
    #     ydotool
    #   ];
    # };
  };
### END -- CUSTOM HOME MANAGER MODULES CONFIGURATION -- END ###

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  programs = {
    home-manager.enable = true;

    emacs = {
      enable = true;
      extraConfig = ''
        (use-package qml-ts-mode
          :after lsp-mode
          :config
          (add-to-list 'lsp-language-id-configuration '(qml-ts-mode . "qml-ts"))
          (lsp-register-client
           (make-lsp-client :new-connection (lsp-stdio-connection '("qmlls", "-E"))
                            :activation-fn (lsp-activate-on "qml-ts")
                            :server-id 'qmlls))
          (add-hook 'qml-ts-mode-hook (lambda ()
                                        (setq-local electric-indent-chars '(?\n ?\( ?\) ?{ ?\] ?\; ?,))
                                        (lsp-deferred))))
      '';
    };
  };

  programs.rio.enable = true;
  programs.kitty.font.name = "JetBrainsMono Nerd Font";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
