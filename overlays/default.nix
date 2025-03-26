{
  # 导入自定义包并添加到nixpkgs
  additions = final: prev: import ../pkgs { pkgs = final; };

  # 为已有包添加修改
  modifications = final: prev: {
    # 示例：修改某个包
    # somePackage = prev.somePackage.override { ... };
  };
}