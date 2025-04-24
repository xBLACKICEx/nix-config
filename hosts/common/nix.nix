{ lib
, pkgs
, inputs
, ...
}: {
  # 所有平台上的 Nix 通用设置
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # 启用实验性功能（适用于任何平台，包括 macOS）
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        auto-optimise-store = true; # 自动优化 Nix 存储

        # 通用的二进制缓存配置
        # extra-substituters = [
        #   "https://anyrun.cachix.org"
        # ];
        # extra-trusted-public-keys = [
        #   "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        # ];
      };
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = [ "/etc/nix/path" ] ++ lib.mapAttrsToList (flakeName: _: "${flakeName}=flake:${flakeName}") flakeInputs;
    };

  # 通用的 Nix 工具，适用于任何使用 Nix 的系统
  environment.systemPackages = with pkgs; [
    # Nix 开发工具
    nil # Nix 语言服务器
    nixd # 另一个 Nix 语言服务器
    nixpkgs-fmt # Nixpkgs 格式化工具

    # Nix 增强工具
    nix-output-monitor # (nom) Nix 构建输出监视工具
    nix-prefetch # 用于获取源码哈希值
    # manix           # Nix 文档搜索工具

    # 通用 Nix 开发工具
    # direnv          # 环境管理工具，通常与 nix-direnv 一起使用
  ];
}
