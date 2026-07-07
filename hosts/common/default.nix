{ lib, ... }: {
  imports = [
    ./nix.nix
    ./pkgs.nix
  ];

  security.sudo.enable = lib.mkForce false;

  security.sudo-rs = {
    enable = true;

    wheelNeedsPassword = true;
  };
}
