{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  mylib,
  ...
}:
let
  codexCli = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # caelestiaPackage = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.override {
  #   app2unit = pkgs.app2unit;
  # };
in
{
  imports = [
    ../common

    outputs.homeManagerModules.fcitx5
    # outputs.homeManagerModules.desktop

    # inputs.illogical-impulse.homeManagerModules.default

    inputs.caelestia-shell.homeManagerModules.default
    inputs.codex-desktop-linux.homeManagerModules.default

    # # The local Waywallen checkout currently exposes `programs` beside an
    # # explicit `config`, which Home Manager rejects. Normalize it here until
    # # the upstream module is fixed.
    # (
    #   {
    #     config,
    #     lib,
    #     pkgs,
    #     ...
    #   }@moduleArgs:
    #   let
    #     waywallenModule = inputs.waywallen.homeModules.default moduleArgs;
    #   in
    #   (builtins.removeAttrs waywallenModule [ "programs" ])
    #   // {
    #     config = lib.mkMerge [
    #       (waywallenModule.config or { })
    #       { programs = waywallenModule.programs or { }; }
    #     ];
    #   }
    # )
    # inputs.waywallen-display.homeModules.default
    # inputs.open-wallpaper-engine.homeModules.default

    # inputs.dms.homeModules.dank-material-shell
    # inputs.dms-plugin-registry.nixosModules.default
    # inputs.danksearch.homeModules.default

    # DeepSeek Harness：声明 profile、种子文件与 `$DSH_HOME/cordis.patch.yml`。
    # 需要全局 pkgs 里已有 `dsh`（见 hosts/common/pkgs.nix 的 overlay）。
    # Web UI 由下方的 `services.dsh` 使用同一份 profile 启动。
    inputs.deepseek-harness.homeModules.default
    outputs.homeManagerModules.headroom

  ];

  home = {
    # 注意修改这里的用户名与用户目录
    # username = username;
    # homeDirectory = "/home/beatrice";

    packages = with pkgs; [
      # 一些常用的软件
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

      # Codex CLI is shared with the Desktop launcher below. Node.js is needed
      # by plugin-provided MCP servers such as codex-security.
      codexCli
      nodejs_22

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
      # kikoplay

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

    stateVersion = "26.11";
  };

  # programs.waywallen = {
  #   enable = true;

  #   display.backend = "kde";

  #   plugins.openWallpaperEngine = {
  #     enable = true;
  #     resolution = "5120x2160";
  #     fps = 30;
  #     msaa = 2;
  #   };
  # };

  ### BEGIN -- CUSTOM HOME MANAGER MODULES CONFIGURATION -- BEGIN ###
  # desktop.hypr.enable = tru

  # illogical-impulse = {
  #   # Enable Dotfiles
  #   enable = true;
  #   hyprland = {
  #     # Use customize hyprland packages
  #     package = hypr.hyprland;
  #     xdgPortalPackage = hypr.xdg-desktop-portal-hyprland;
  #     # Set NIXOS_OZONE_WL=1
  #     ozoneWayland.enable = true;
  #   };
  #   dotfiles = {
  #     fish.enable = true;
  #     kitty.enable = true;
  #   };
  # };
  ### END -- CUSTOM HOME MANAGER MODULES CONFIGURATION -- END ###

  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # programs.dank-material-shell = {
  #   enable = true;

  #   systemd = {
  #     enable = true;             # Systemd service for auto-start
  #     restartIfChanged = true;   # Auto-restart dms.service when dankMaterialShell changes
  #   };
  #   plugins = {
  #     dankBatteryAlerts.enable = true;
  #     dockerManager.enable = true;
  #     dankPomodoroTimer.enable = true;
  #     linuxWallpaperEngine.enable = true;
  #     # DockerManager = {
  #     #   enable = true;
  #     #   src = pkgs.fetchFromGitHub {
  #     #     owner = "LuckShiba";
  #     #     repo = "DmsDockerManager";
  #     #     rev = "v1.2.0";
  #     #     sha256 = "sha256-VoJCaygWnKpv0s0pqTOmzZnPM922qPDMHk4EPcgVnaU=";
  #     #   };
  #     # };
  #     # DankPomodoroTimer.src = "${inputs.dms-plugins}/DankPomodoroTimer";
  #     # DankBatteryAlerts.src = "${inputs.dms-plugins}/DankBattery Alerts";
  #     # dms-wallpaperengine.src = "${inputs.dms-wallpaperengine}";
  #   };

  #   enableSystemMonitoring = true;     # System monitoring widgets (dgop)
  #   enableClipboardPaste = true;            # Clipboard history manager
  #   enableVPN = true;                  # VPN management widget
  #   enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
  #   enableAudioWavelength = true;      # Audio visualizer (cava)
  #   enableCalendarEvents = true;       # Calendar integration (khal)
  # };
  # programs.dsearch.enable = true;

  programs = {
    home-manager.enable = true;

    codexDesktopLinux = {
      enable = true;
      cliPackage = codexCli;
    };

    nushell.plugins = [
    ];

    nushell.extraConfig = lib.mkAfter ''
      use ${inputs.dotfiles}/apps/nushell/nixos/mod.nu *
    '';

    nushell.extraLogin = ''
      uwsm check may-start -i ; uwsm select ; exec uwsm start default
    '';
    bash.profileExtra = ''
      if uwsm check may-start && uwsm select; then
        exec uwsm start default
      fi
    '';


    git.settings = {
      safe = {
        directory = "/home/shards/nixconfig";
      };
    };

    # rio.enable = true;
    # kitty.font.name = "JetBrainsMono Nerd Font";

    # caelestia = {
    #   enable = true;
    #   # package = caelestiaPackage;
    #   systemd = {
    #     enable = true; # if you prefer starting from your compositor
    #     target = "graphical-session.target";
    #     environment = [];
    #   };

    #   settings = {
    #     bar.statusIcons = [
    #       { id = "lockStatus"; enabled = true; }
    #       { id = "network"; enabled = true; }
    #       { id = "bluetooth"; enabled = true; }
    #       { id = "battery"; enabled = false; }
    #     ];
    #     paths.wallpaperDir = "~/Pictures/wallpapers";
    #     appearance.transparency.enabled = true;
    #   };

    #   # 命令行工具设置
    #   cli = {
    #     enable = true; # 将 caelestia-cli 添加到 PATH
    #     settings = {
    #       theme.enableGtk = true;
    #     };
    #   };
    # };
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
  };

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

    # dsh 0.2.2-rc.1 的 flake 把 @linxin666/* 以 `link:` 依赖投影到 profile 的
    # node_modules（符号链接指向 /nix/store）。Node 默认把 importer realpath 成
    # store 路径，而这些包里直接 import 的 @deepseek-ai/cordis、dsh-settings、
    # dsh-llm 等并没有写进 peerDependencies，dsh 的 linked-root 解析器只改写
    # 声明过的 peer，于是启动时 9 个 bundle ERR_MODULE_NOT_FOUND。
    # 保留符号链接后 importer 留在 profile 内，走 profile 层解析，所有
    # @deepseek-ai/* 都会被路由回 dsh 安装自带的副本。上游修好后可删除。
    environment.NODE_OPTIONS = "--preserve-symlinks";
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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
