{ inputs, lib, pkgs, ... }:
let
  private = import (inputs.nix-config-private + "/flake-input/reva.nix");
  interface = "wlp15s0";
  bridge = "br-reva-ap";
  routerUuid = "76da544a-4dfb-4df8-9b1c-7c0efaa8dfe1";
  uplinkUuid = "3a77fa4e-958a-4bd4-b8c6-9c0e99263da0";
  passwordFile = "/var/lib/reva-ap/password";

  # The hotspot password is supplied locally, outside the Nix store.
  makeHotspot = { sixGHz, bridgeUplink ? false }: {
    # The only Wi-Fi device is owned by hostapd.
    networking.wireless.enable = lib.mkForce false;
    networking.networkmanager = {
      unmanaged = [ "interface-name:${interface}" ];
      ensureProfiles.profiles = {
        reva-ap-router = {
          connection = {
            id = "REVA-AP";
            uuid = routerUuid;
            type = "bridge";
            interface-name = bridge;
            autoconnect = false;
          };
          bridge.stp = false;
          ipv4 = {
            method = if bridgeUplink then "auto" else "shared";
          } // lib.optionalAttrs (!bridgeUplink) {
            address1 = private.hotspot.address;
          };
          ipv6 = {
            method = if bridgeUplink then "auto" else "shared";
            may-fail = true;
          };
        } // lib.optionalAttrs bridgeUplink {
          # A stable software MAC avoids changes when hostapd adds its port.
          ethernet.cloned-mac-address = "stable";
        };
      } // lib.optionalAttrs bridgeUplink {
        reva-ap-uplink = {
          connection = {
            id = "REVA-AP-uplink";
            uuid = uplinkUuid;
            type = "ethernet";
            interface-name = "enp14s0";
            controller = routerUuid;
            port-type = "bridge";
            autoconnect = false;
          };
        };
      };
    };

    networking.firewall.interfaces.${bridge} = {
      allowedUDPPorts = [ 53 67 ];
      allowedTCPPorts = [ 53 private.hotspot.iperfPort private.telescope.port ];
    };

    # Docker may drop bridged IPv4 frames when br_netfilter is enabled.
    # Exempt only frames bridged between this AP and its wired LAN uplink.
    networking.firewall.extraCommands = lib.mkIf bridgeUplink (lib.mkAfter ''
      for tool in iptables ip6tables; do
        for ports in "${interface} enp14s0" "enp14s0 ${interface}"; do
          read -r incoming outgoing <<< "$ports"
          $tool -w -C FORWARD -m physdev --physdev-is-bridged \
            --physdev-in "$incoming" --physdev-out "$outgoing" -j ACCEPT 2>/dev/null || \
          $tool -w -I FORWARD 1 -m physdev --physdev-is-bridged \
            --physdev-in "$incoming" --physdev-out "$outgoing" -j ACCEPT
        done
      done
    '');
    networking.firewall.extraStopCommands = lib.mkIf bridgeUplink (lib.mkAfter ''
      for tool in iptables ip6tables; do
        for ports in "${interface} enp14s0" "enp14s0 ${interface}"; do
          read -r incoming outgoing <<< "$ports"
          $tool -w -D FORWARD -m physdev --physdev-is-bridged \
            --physdev-in "$incoming" --physdev-out "$outgoing" -j ACCEPT 2>/dev/null || true
        done
      done
    '');

    # Require an explicitly supplied password; do not import old hotspot secrets.
    systemd.services.reva-ap-password = {
      description = "Prepare REVA-AP hotspot password";
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "reva-ap";
        StateDirectoryMode = "0700";
        UMask = "0077";
      };
      script = ''
        if [ ! -s ${passwordFile} ]; then
          echo "Set ${passwordFile} to the hotspot passphrase (root-only)." >&2
          exit 1
        fi
      '';
    };

    systemd.services.reva-ap-router = {
      description = "REVA-AP hotspot ${if bridgeUplink then "wired LAN" else "IPv4/IPv6 sharing"} bridge";
      requires = [ "NetworkManager.service" "NetworkManager-ensure-profiles.service" ];
      after = [ "NetworkManager.service" "NetworkManager-ensure-profiles.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.networkmanager}/bin/nmcli --wait 30 connection up uuid ${if bridgeUplink then uplinkUuid else routerUuid}";
        ExecStop = "-${pkgs.networkmanager}/bin/nmcli --wait 10 connection down uuid ${routerUuid}";
      };
    };

    services.hostapd = {
      enable = true;
      radios.${interface} = {
        countryCode = private.wirelessCountry;
        band = if sixGHz then "6g" else "5g";
        channel = if sixGHz then 5 else 36;
        wifi4.enable = !sixGHz;
        wifi4.capabilities = [ "HT40+" "SHORT-GI-20" "SHORT-GI-40" ];
        wifi5.enable = !sixGHz;
        wifi5.operatingChannelWidth = "80";
        wifi5.capabilities = [ "SHORT-GI-80" "MAX-A-MPDU-LEN-EXP7" ];
        wifi6 = {
          enable = true;
          operatingChannelWidth = if sixGHz then "160" else "80";
        };
        wifi7.enable = false;
        settings = {
          he_oper_centr_freq_seg0_idx = if sixGHz then 15 else 42;
        } // lib.optionalAttrs sixGHz {
          # 6 GHz width is derived from operating class, not he_oper_chwidth.
          op_class = 134;
          he_6ghz_reg_pwr_type = 0; # Indoor low-power AP, subject to FR regdb.
          he_6ghz_max_ampdu_len_exp = 7;
          he_6ghz_max_mpdu = 2;
        } // lib.optionalAttrs (!sixGHz) {
          vht_oper_centr_freq_seg0_idx = 42;
        };
        networks.${interface} = {
          ssid = "REVA-AP";
          settings = {
            bridge = bridge;
            sae_pwe = lib.mkForce (if sixGHz then 1 else 2);
          };
          authentication = {
            mode = "wpa3-sae";
            enableRecommendedPairwiseCiphers = false;
            pairwiseCiphers = [ "CCMP" ];
            saePasswords = [ { inherit passwordFile; } ];
          };
        };
      };
    };
    systemd.services.hostapd = {
      requires = [ "reva-ap-password.service" "reva-ap-router.service" ];
      after = [ "reva-ap-password.service" "reva-ap-router.service" ];
      restartTriggers = [ (pkgs.writeText "reva-ap-mode" (if bridgeUplink then "lan" else "routed")) ];
    };
  };
in
makeHotspot { sixGHz = true; } // {
  # REVA defaults to the routed 6 GHz hotspot, including after reboot.
  # Alternative configurations, kept disabled for reference:
  # makeHotspot { sixGHz = false; }
  # makeHotspot { sixGHz = true; bridgeUplink = true; }
}
