{
  pkgs,
  inputs,
  lib,
  ...
}: {
  # How to enter setup mode and Enrolling Keys- HP Plavilion LapTop
  ## 1. enter BIOS via F10 Key
  ## 2. <Boot Options>  => <Secure Boot>
  ## 3. Press `Clear All Secure Boot Keys`
  ## 4. Press F10 to saving and reboot.
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
  ];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
