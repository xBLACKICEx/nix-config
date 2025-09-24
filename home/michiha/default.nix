{ pkgs, inputs, outputs, ... }:

{
  # 注意修改这里的用户名与用户目录
  # home.username = username;
  # home.homeDirectory = "/home/michiha";  # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置

  # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # 递归整个文件夹
  #   executable = true;  # 将其中所有文件添加「执行」权限
  # };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  imports = [
    ../common
    # 导入一些常用的配置
    inputs.zen-browser.homeModules.beta
    outputs.homeManagerModules.fcitx5
  ];

  # 通过 home.packages 安装一些常用的软件
  # 这些软件将仅在当前用户下可用，不会影响系统级别的配置
  # 建议将所有 GUI 软件，以及与 OS 关系不大的 CLI 软件，都通过 home.packages 安装
  home.packages = with pkgs; [

    # (inputs.zen-browser.packages.${pkgs.system}.default.override
    #   {
    #     extraPrefsFiles = [
    #       (builtins.fetchurl {
    #         url = "https://raw.githubusercontent.com/MrOtherGuy/fx-autoconfig/master/program/config.js";
    #         sha256 = "1mx679fbc4d9x4bnqajqx5a95y1lfasvf90pbqkh9sm3ch945p40";
    #       })
    #     ];
    #   }
    #   { })

    anytype

    # 终端文件管理器
    # yazi

    # 常用工具
    ripgrep # 递归搜索目录中的正则表达式模式
    fd # find 的替代品
    jq # 轻量级且灵活的命令行 JSON 处理器
    yq-go # YAML 处理器 https://github.com/mikefarah/yq
    lsd

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
    exercism
    devenv
    jetbrains-toolbox
    libreoffice-qt6

    carapace

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
    # wechat-uos
    qq
  ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
    };
  };

  # git 相关配置
  programs.git = {
    extraConfig = {
      safe = {
        directory = "/home/shards/nixconfig";
      };
    };
  };

  programs.vscode = {
    enable = true;
  };

  # programs.nushell.enable = true;

  programs.emacs = {
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
