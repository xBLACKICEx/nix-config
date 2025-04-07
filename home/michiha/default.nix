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
    # 导入一些常用的配置
    outputs.homeManagerModules.fcitx5
  ];

  # 通过 home.packages 安装一些常用的软件
  # 这些软件将仅在当前用户下可用，不会影响系统级别的配置
  # 建议将所有 GUI 软件，以及与 OS 关系不大的 CLI 软件，都通过 home.packages 安装
  home.packages = with pkgs;[
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


  # git 相关配置
  programs.git = {
    enable = true;
    userName = "xblackicex";
    userEmail = "xblackicex@outlook.com";
  };

  services.pueue.enable = true;
  services.pueue.settings = {
    client = {
      restart_in_place = false;
      read_local_logs = true;
      show_confirmation_questions = false;
      show_expanded_aliases = false;
      dark_mode = false;
      max_status_lines = null;
      status_time_format = "%H:%M:%S";
      status_datetime_format = "%Y-%m-%d\n%H:%M:%S";
    };
    daemon = {
      pause_group_on_failure = false;
      pause_all_on_failure = false;
      callback = null;
      env_vars = { };
      callback_log_lines = 10;
      shell_command = null;
    };
    shared = {
      pueue_directory = null;
      runtime_directory = null;
      alias_file = null;
      use_unix_socket = true;
      unix_socket_path = null;
      host = "127.0.0.1";
      port = "6924";
      pid_path = null;
      daemon_cert = null;
      daemon_key = null;
      shared_secret_path = null;
    };
    profiles = { };
  };

  # # 启用 starship，这是一个漂亮的 shell 提示符
  # programs.starship = {
  #   enable = true;
  #   # 自定义配置
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    # enableNushellIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
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

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO 在这里添加你的自定义 bashrc 内容
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      eval "$(starship init bash)"
      eval "$(zoxide init bash)"
      alias ls=lsd;
    '';

    # TODO 设置一些别名方便使用，你可以根据自己的需要进行增删
    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
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
