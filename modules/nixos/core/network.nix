{ config, inputs, lib, pkgs, ... }:
let
  dnscryptEnabled = config.services.dnscrypt-proxy.enable;
in
{
  # Network
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.interfaces.enp113s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  networking.networkmanager.enable = true;

  # Only redirect DNS to localhost when DNSCrypt owns the resolver.
  networking.nameservers = lib.mkIf dnscryptEnabled [ "127.0.0.1" ];
  networking.dhcpcd.extraConfig = lib.mkIf dnscryptEnabled "nohook resolv.conf";
  networking.networkmanager.dns = lib.mkIf dnscryptEnabled "none";

  services.dnscrypt-proxy = {
    enable = lib.mkDefault true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" ];
      # Read at build/evaluation time so a missing private file cannot produce
      # a system whose sole DNS resolver fails only after activation.
      forwarding_rules = pkgs.writeText "dnscrypt-forwarding-rules.txt"
        (builtins.readFile (inputs.nix-config-private + "/flake-input/dnscrypt-forwarding-rules.txt"));
      ipv6_servers = true;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };

      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      # server_names = [ ... ];
    };
  };
}
