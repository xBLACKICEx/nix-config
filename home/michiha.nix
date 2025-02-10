{ pkgs, outputs, ... }:

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
    # 如下是我常用的一些命令行工具，你可以根据自己的需要进行增删

    yazi # terminal file manager

    # utils
    ripgrep # recursively searches directories for a regex pattern
    fd # replacement of find
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    lsd

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    gnused
    gnutar
    gawk
    zstd
    gnupg
    keepassxc

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output


    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    warp-terminal

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    brightnessctl # control the brightness of the screen, for hyprland
    # pueue #  A command scheduler for shells https://github.com/Nukesor/pueue

    # 聊天工具
    telegram-desktop
    element-desktop
    discord
    zed-editor
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


  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO 在这里添加你的自定义 bashrc 内容
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
