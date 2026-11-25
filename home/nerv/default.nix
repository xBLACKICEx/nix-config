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
in
{
  imports = [
    ../common
    outputs.homeManagerModules.fcitx5
  ];

  home = {
    packages = with pkgs; [
      # 一些常用的软件
      anytype

      # 常用工具
      yq-go # YAML 处理器 https://github.com/mikefarah/yq
      vscode

      # Codex CLI is shared with the Desktop launcher below. Node.js is needed
      # by plugin-provided MCP servers such as codex-security.

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
      gnupg
      keepassxc
    ];


    stateVersion = "26.11";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };


  programs = {
    home-manager.enable = true;


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
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
}
