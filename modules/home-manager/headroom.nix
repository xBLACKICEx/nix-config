{ config
, lib
, pkgs
, inputs
, ...
}:
let
  cfg = config.services.headroom;

  # 一个 `headroom proxy` 对每种协议形状（`/v1/messages`、
  # `/v1/chat/completions`、`/v1/responses`）只有一个上游，所以「同一台机器上
  # 同时给两家网关做压缩」要靠多个实例：各绑自己的端口、指向各自的上游，客户端
  # 按端口选。压缩策略不在这里传参数，即 Headroom 默认（`coding` savings
  # profile / `cache` 模式，见 https://docs.headroomlabs.ai/docs/proxy）。
  upstreamOptions = {
    anthropicApiUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Anthropic 形状（`/v1/messages`）流量的上游根地址。`null` 表示不传
        `--anthropic-api-url`，沿用 Headroom 自带的默认值。
      '';
    };

    openaiApiUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        OpenAI 形状（`/v1/chat/completions`、`/v1/responses`、`/v1/models`）
        流量的上游根地址。`null` 表示沿用 Headroom 自带的默认值。Headroom 会把
        该值末尾的 `/v1` 归一化掉，再拼上进来的请求路径，因此这里写
        `https://host/v1` 和 `https://host` 等价。
      '';
    };

    providerName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "仪表盘上给这个上游显示的名字；只影响显示，不影响路由。";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--no-learn" ];
      description = "追加到 `headroom proxy` 之后的额外命令行参数。";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = { HEADROOM_BEACON = "off"; };
      description = "该实例的额外环境变量。";
    };
  };

  instanceArgs = instance: [
    "${cfg.package}/bin/headroom"
    "proxy"
    "--host"
    cfg.host
    "--port"
    (toString instance.port)
  ]
  ++ lib.optionals (instance.anthropicApiUrl != null) [ "--anthropic-api-url" instance.anthropicApiUrl ]
  ++ lib.optionals (instance.openaiApiUrl != null) [ "--openai-api-url" instance.openaiApiUrl ]
  ++ lib.optionals (instance.providerName != null) [ "--provider-name" instance.providerName ]
  ++ instance.extraArgs;

  mkUnit = label: instance: {
    Unit = {
      Description = "Headroom context-compression proxy (${label})";
      Documentation = [ "https://docs.headroomlabs.ai/docs/proxy" ];
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      # systemd does not invoke a shell for ExecStart.  Quote every argument
      # using its own syntax so values such as "OpenCode Go" remain one
      # argument rather than being split on whitespace.
      ExecStart = lib.hm.strings.escapeSystemdExecArgs (instanceArgs instance);
      Environment = lib.mapAttrsToList (name: value: "${name}=${value}") instance.environment;
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  primary = {
    inherit (cfg) port anthropicApiUrl openaiApiUrl providerName extraArgs environment;
  };
in
{
  options.services.headroom = upstreamOptions // {
    enable = lib.mkEnableOption "Headroom 上下文压缩代理";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/headroom.nix {
        inherit (inputs) uv2nix pyproject-nix pyproject-build-systems;
      };
      defaultText = lib.literalExpression "pkgs.callPackage ../../pkgs/headroom.nix { inherit (inputs) uv2nix pyproject-nix pyproject-build-systems; }";
      description = "提供 `headroom` 命令的包。";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "所有实例绑定的地址。";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8787;
      description = "主实例的 TCP 端口，对应 systemd user 单元 `headroom`。";
    };

    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = upstreamOptions // {
          port = lib.mkOption {
            type = lib.types.port;
            description = "该实例的 TCP 端口，对应 systemd user 单元 `headroom-<名字>`。";
          };
        };
      });
      default = { };
      example = lib.literalExpression ''
        {
          opencode-go = {
            port = 8788;
            providerName = "OpenCode Go";
            anthropicApiUrl = "https://opencode.ai/zen/go";
            openaiApiUrl = "https://opencode.ai/zen/go/v1";
          };
        }
      '';
      description = "主实例之外的额外代理实例，各自有端口与上游。";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services = {
      headroom = mkUnit "primary" primary;
    } // lib.mapAttrs' (name: instance: lib.nameValuePair "headroom-${name}" (mkUnit name instance)) cfg.instances;
  };
}
