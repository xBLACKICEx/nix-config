{ pkgs
, inputs
, outputs
, lib
, ...
}:
let
  commonUserGroups = [
    "audio"
    "dialout"
    "input"
    "kvm"
    "libvirtd"
    "networkmanager"
    "plugdev"
    "qemu-libvirtd"
    "shared"
    "video"
    "wheel"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./impermanence.nix
    outputs.nixosModules.core
    outputs.nixosModules.desktop
    # outputs.nixosModules.agentdock
    inputs.dank-greeter.nixosModules.default
  ];

  # age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # age.secrets.ionos-acme = {
  #   file = ../../secrets/ionos-acme.env.age;
  #   owner = "root";
  #   group = "root";
  #   mode = "0400";
  # };

  # security.acme = {
  #   acceptTerms = true;
  #   certs."mcp.xblackicex.me" = {
  #     server = "https://acme-v02.api.letsencrypt.org/directory";
  #     dnsProvider = "ionos";
  #     environmentFile = config.age.secrets.ionos-acme.path;
  #     group = config.services.nginx.group;
  #   };
  # };

  services.nginx = {
    enable = false;
    virtualHosts."mcp.xblackicex.me" = {
      onlySSL = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      useACMEHost = "mcp.xblackicex.me";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8765";
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Connection "";
          proxy_buffering off;
          proxy_cache off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  networking.hostName = "suzuha";
  system.stateVersion = lib.mkForce "26.11";

  # Desktop
  desktop.hypr.enable = true;
  desktop.kde.enable = true;
  desktop.niri.enable = false;
  # desktop.cosmic.enable = true;
  programs.dms-greeter = {
    enable = false;
    compositor.name = "niri";

    # compositor.customConfig = ''
    #   env = DMS_RUN_GREETER,1

    #   monitor = DP-1, 5120x2160@100.03, 0x0, 1.25, bitdepth, 12
    #   monitor = eDP-1, 1920x1080@60, 1088x1728, 1

    #   misc {
    #     disable_hyprland_logo = true
    #   }
    # '';
  };

  # Remote desktop / streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };

  # Security / keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Optional desktop/display alternatives
  # services.xserver.desktopManager.deepin.enable = true;
  # services.deepin.deepin-anything.enable = true;
  # services.deepin.dde-daemon.enable = true;
  # services.deepin.dde-api.enable = true;
  # services.deepin.app-services.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   autoNumlock = true;
  #   wayland.enable = true;
  #   enableHidpi = true;
  # };
  # services.xserver.enable = true;

  # Programs
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.virt-manager.enable = true;

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = false;
  virtualisation.spiceUSBRedirection.enable = true;
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bash}/bin/bash -c 'umask 0077 && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --with-key=host --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  ];
  # virtualisation.virtualbox.host.enable = true;


  # Networking / discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.syncthing.enable = true;

  # services.agentdock = {
  #   enable = true;
  #   user = "michiha";
  #   workspace = "/home/michiha/AgentDock";
  #   tunnel.enable = false;
  #   oauth = {
  #     enable = true;
  #     serverUrl = "https://mcp.xblackicex.me";
  #   };
  # };

  # Printing / scanning
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ cnijfilter2 ];
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    firefox
    google-chrome
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    jetbrains.clion
    jetbrains.datagrip
    jetbrains.goland
    jetbrains.rust-rover
    kdePackages.qtdeclarative
    kdePackages.qt5compat
    # kdePackages.wallpaper-engine-plugin
    # kdePackages.neochat
    moonlight-qt
    simple-scan
    zed-editor

    stm32cubemx
  ];

  # Groups
  users.groups = {
    docker.members = [ "michiha" ];
    libvirtd.members = [ "michiha" ];
    plugdev = { };
    shared = { };
    syncthing-shared = { };
    configs = { };
  };
  users.extraGroups.vboxusers.members = [ "michiha" ];

  # Users
  users.users = {
    root = {
      hashedPassword = "$6$BKXv3QWuBJAnRYNK$uP.PDS1qmkCDvr2IBLw9mLyNhUP0Js7hGfPYBnRTE3Jc8Om24/ae/O6hn7jH58eCYM9L7zIM7EXb9es.10iO00";
    };
    michiha = {
      linger = true;
      hashedPassword = "$6$iBSb93jkx9FGya9x$q7riq6BxEZhXyNAoVCvPc62Br98Y2x69U4lgME8H4cJbXpebRVZsT7NZhhw2h1zumLuVZtJF.ZyXVicNQr1/7.";
      isNormalUser = true;
      description = "michiha";
      enable = true;
      extraGroups = commonUserGroups ++ [
        "docker"
        "scanner"
        "lp"
        "configs"
        "syncthing-shared"
      ];
    };

  };

  # Nix
  nix.settings.trusted-users = [ "michiha" ];
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
