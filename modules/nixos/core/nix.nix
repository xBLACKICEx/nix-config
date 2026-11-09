{ pkgs, ... }: {
  # Private flake inputs are also fetched by root during nixos-rebuild.
  # Fingerprint: https://docs.codeberg.org/security/ssh-fingerprint/
  programs.ssh.knownHosts."codeberg.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";

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

  nix.optimise.automatic = true;
}
