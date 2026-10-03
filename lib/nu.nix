# 把内联 nushell 脚本变成可直接执行的 shell 命令。
# 用 `nu -c` + lib.escapeShellArg 传脚本：不需要 store 文件，脚本里的
# 单/双引号、`$` 变量都能照写。
#
# 注意：脚本里出现 `${` 时要按 Nix 缩进字符串的规矩写成 `''${`。
{ lib, package }:
rec {
  # `nu --no-config-file -c '<script>'`
  exec = script: "${lib.getExe package} --no-config-file -c ${lib.escapeShellArg script}";

  # home-manager activation 版：外面套一层 `run`。
  run = script: "run ${exec script}";
}
