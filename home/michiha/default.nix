{ pkgs, inputs, outputs, config, lib, mylib, ... }:
let
  codexCli = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # home = {
  #   # 注意修改这里的用户名与用户目录
  #   username = username;
  #   homeDirectory = "/home/michiha";
  #
  #   # 直接将当前文件夹的配置文件，链接到 Home 目录下的指定位置
  #   file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;
  #
  #   # 递归将某个文件夹中的文件，链接到 Home 目录下的指定位置
  #   file.".config/i3/scripts" = {
  #     source = ./scripts;
  #     recursive = true;   # 递归整个文件夹
  #     executable = true;  # 将其中所有文件添加「执行」权限
  #   };
  #
  #   # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  #   file.".xxx".text = ''
  #       xxx
  #   '';
  # };

  imports = [
    ../common
    # 导入一些常用的配置
    outputs.homeManagerModules.fcitx5
    outputs.homeManagerModules.headroom
    inputs.codex-desktop-linux.homeManagerModules.default
    # DeepSeek Harness：声明 profile、种子文件与 `$DSH_HOME/cordis.patch.yml`。
    # 需要全局 pkgs 里已有 `dsh`（见 hosts/common/pkgs.nix 的 overlay）。
    # Web UI 由下方的 `services.dsh` 使用同一份 profile 启动。
    inputs.deepseek-harness.homeModules.default
  ];

  home = {
    # 通过 packages 安装一些常用的软件
    # 这些软件将仅在当前用户下可用，不会影响系统级别的配置
    # 建议将所有 GUI 软件，以及与 OS 关系不大的 CLI 软件，都通过 packages 安装
    packages = with pkgs; [
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

      codexCli
      nodejs_22

      # kikoplay
      exercism
      devenv
      jetbrains-toolbox
      libreoffice-qt6

      carapace

      # editors
      helix
      # helix-gpt

      # 效率工具
      hugo # 静态站点生成器
      glow # 终端中的 Markdown 预览器

      btop # htop/nmon 的替代品
      iotop # IO 监控
      iftop # 网络监控

      # 系统调用监控
      strace # 系统调用监控
      # ltrace # 库调用监控
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
      # qq
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "26.11";
  };

  programs = {
    # git 相关配置
    git.settings = {
      safe = {
        directory = "/home/shards/nixconfig";
      };
    };

    vscode.enable = true;

    # nushell.enable = true;


    codexDesktopLinux = {
      enable = true;
      cliPackage = codexCli;
    };

    # DeepSeek Harness：CLI、profile 与 Web UI 全部交给 Home Manager 管理，
    # 取代原来手工执行的
    #   DEEPSEEK_BASE_URL=http://127.0.0.1:8787/v1 \
    #     nix run github:moraxyc/deepseek-harness.nix#presets.web-ui --accept-flake-config
    dsh = {
      enable = true;

      profiles.web-ui = {
        # 等价于上游 `presets.web-ui`：base 层由模块隐式加入，这里只列额外的
        # bundle（与 presets/web-ui/package.nix 保持一致）。
        bundles = [
          pkgs.dsh.bundles.web-app
          pkgs.dsh.bundles.web-ui
        ];

        # mutable：Nix 只在 `~/.dsh/profiles/nix-web-ui` 不存在时播种一次，
        # 之后插件与设置完全由 `dsh plugin` 管理，Nix 不再覆盖本地改动。
        mode = "mutable";
      };

      defaultProfile = config.programs.dsh.profiles.web-ui.materializedName;

      # provider → Headroom 的接线。home 级 patch 会被同步到
      # `$DSH_HOME/cordis.patch.yml`，在每个 profile 的 patch 之后应用，因此
      # 不管怎么启动 dsh（CLI、Web、headless）都生效，也不依赖 session 变量：
      #   llm-deepseek → 8787（DeepSeek 官方）
      #   opencode-go  → 8788（OpenCode Go）
      # 凭据仍由各自的 credentials 解析（DEEPSEEK_API_KEY / OPENCODE_API_KEY），
      # Headroom 只做压缩与转发。
      patch = [
        {
          id = "llm-deepseek";
          config.baseURL = "http://127.0.0.1:8787/v1";
        }
        {
          id = "opencode-go";
          config.baseURL = "http://127.0.0.1:8788/v1";
        }
      ];
    };

    nushell.extraConfig = lib.mkAfter ''
      use ${inputs.dotfiles}/apps/nushell/nixos/mod.nu *
    '';

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  # Headroom 上下文压缩代理：常驻本机，压缩 DSH 的上下文。
  # 一个代理每种协议形状只有一个上游，所以按上游拆成两个实例：
  #   headroom            127.0.0.1:8787 → DeepSeek 官方（原生 API，只是先压缩）
  #   headroom-opencode-go 127.0.0.1:8788 → OpenCode Zen Go 网关
  # 压缩策略不传参，用 Headroom 默认（`coding` profile / `cache` 模式）。
  # 默认的 CCR 模式不需要 DSH 这边做任何事：代理会把 `headroom_retrieve`
  # 工具注入上游请求，并在响应里自己拦下模型的取回调用（Anthropic / OpenAI
  # 路径对客户端透明），原始内容放在 `~/.headroom/ccr_store.db`（SQLite，
  # 默认 TTL 1800s），两个实例共用同一份。只有在完全不想要标记时才需要
  # `extraArgs = [ "--lossless" ]`（代价是没有取回回合，压缩也更保守）。
  services.headroom = {
    enable = true;

    # 主实例：DSH 的 `deepseek-official`（Messages 协议）走这里，
    # 上游仍然是 DeepSeek 自己的 API；chat-completions 协议也一并指过去。
    anthropicApiUrl = "https://api.deepseek.com/anthropic";
    openaiApiUrl = "https://api.deepseek.com/v1";

    # OpenCode Go 订阅的模型（deepseek / gpt / claude / 小米…）都在这个网关上，
    # 三种协议形状都转发到同一处，所以一个实例就够。
    instances.opencode-go = {
      port = 8788;
      providerName = "OpenCode Go";
      anthropicApiUrl = "https://opencode.ai/zen/go";
      openaiApiUrl = "https://opencode.ai/zen/go/v1";
    };
  };

  # 唯一的 DSH Web 实例。服务模块会复用上面声明的 mutable profile 和
  # `~/.dsh`，因此不会创建第二套配置；启动顺序上等待主 Headroom 代理就绪。
  services.dsh = {
    enable = true;
    profile = config.programs.dsh.profiles.web-ui.materializedName;
  };

  systemd.user.services.dsh-web.Unit = {
    After = [ "headroom.service" ];
    Wants = [ "headroom.service" ];
  };

  # 上游 bug 兜底：模块用 `writers.writeYAML` 播种 profile 的
  # `pnpm-workspace.yaml`，会在开头带上 `%YAML 1.1` + `---`。pnpm 在 YAML 1.1
  # 语义下把 `packages: [- .]` 里单独的 `.` 解析成 null，于是任何
  # `dsh plugin` 安装都在 `pnpm add` 的最后一步以
  #   ERR_PNPM_INVALID_WORKSPACE_CONFIGURATION: Missing or empty package
  # 失败并被回滚（能浏览/搜索插件，但装不上）。mutable profile 播种后不再被
  # Nix 重写，dsh 自己回写时也会保留该指令头，所以只能在外面剥掉这两行；
  # 其余本地设置（如 allowBuilds）原样保留。
  # 上游修好后（profiles.nix 的 workspace.packages 去掉 "." 即可）可删除本项。
  home.activation.dshFixPnpmWorkspace = lib.hm.dag.entryAfter [ "dsh" ] (mylib.nu.run ''
    let ws = "${config.home.homeDirectory}/.dsh/profiles/${config.programs.dsh.profiles.web-ui.materializedName}/pnpm-workspace.yaml"
    if ($ws | path type) == "file" {
      let raw = (open --raw $ws)
      let fixed = ($raw | str replace --regex '^%YAML 1\.1\n---\n?' "")
      if $fixed != $raw {
        $fixed | save --force $ws
      }
    }
  '');

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
