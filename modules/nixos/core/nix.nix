{ pkgs, ... }: {
  # NixOS 特有的系统级别 Nix 设置
  environment.systemPackages = with pkgs; [
  ];
  nix.gc = {
    dates = "weekly";
    options = "--delete-older-than 30d";
    automatic = true;
  };

  nix.settings = {
    # 可信用户设置（NixOS 特有的系统级别配置）
    # trusted-users = [ "h4x0r_k4n3da" ];
  };
}
