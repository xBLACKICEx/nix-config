{ inputs, lib, ... }:
let
  private = import (inputs.nix-config-private + "/flake-input/reva.nix");
in
{
  imports = [ ./hostapd-hotspot.nix ];

  networking.hostName = "REVA";
  services.dnscrypt-proxy.enable = true;

  # Provide the regulatory database for the boot-time country setting.
  hardware.wirelessRegulatoryDatabase = true;

  # Telescope pairing is reachable from the wired LAN.
  networking.firewall.extraCommands = lib.mkAfter ''
    iptables -w -C nixos-fw -i enp14s0 -s ${private.telescope.wiredSubnet} -p tcp --dport ${toString private.telescope.port} -j nixos-fw-accept 2>/dev/null || \
      iptables -w -I nixos-fw 1 -i enp14s0 -s ${private.telescope.wiredSubnet} -p tcp --dport ${toString private.telescope.port} -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = lib.mkAfter ''
    iptables -w -D nixos-fw -i enp14s0 -s ${private.telescope.wiredSubnet} -p tcp --dport ${toString private.telescope.port} -j nixos-fw-accept 2>/dev/null || true
  '';

  # Remote desktop / streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Networking / discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.syncthing.enable = true;

  programs.steam = {
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
