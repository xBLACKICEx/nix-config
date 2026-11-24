{ config, lib, pkgs, ... }:
let
  libraryDirectories = [
    "/games-lib"
    "/games-lib/steam"
    "/games-lib/steam/steamapps"
    "/games-lib/heroic"
    "/games-lib/lutris"
    "/games-lib/manual"
  ];
  seedGamingSession = pkgs.writeShellApplication {
    name = "seed-gaming-session";
    runtimeInputs = [ pkgs.kdePackages.kconfig pkgs.jq ];
    text = ''
      state_file="$1"
      previous=$(kreadconfig6 --file "$state_file" --group General --key LastLoggedInSession)
      previous_user=$(kreadconfig6 --file "$state_file" --group General --key LastLoggedInUser)
      sessions=$(jq -cn --arg previous "$previous" --arg user "$previous_user" '
        ($previous | try fromjson catch null) as $parsed
        | (if ($parsed | type) == "object" then $parsed
           elif $previous != "" and $user != "" then {($user): $previous}
           else {} end)
        | .gaming = "steam.desktop"
        | .beatrice //= "plasma.desktop"
      ')
      kwriteconfig6 --file "$state_file" --group General --key LastLoggedInSession "$sessions"
    '';
  };
  initializeGamingSession = pkgs.writeShellApplication {
    name = "initialize-gaming-session";
    runtimeInputs = [ pkgs.coreutils seedGamingSession ];
    text = ''
      state_dir="$1/.local/state"
      install -d -m 0700 -o plasmalogin -g plasmalogin "$1/.local" "$state_dir"
      seed-gaming-session "$state_dir/plasma-login-greeterstaterc"
      chown plasmalogin:plasmalogin "$state_dir/plasma-login-greeterstaterc"
      chmod 0600 "$state_dir/plasma-login-greeterstaterc"
    '';
  };
in
{
  users.groups.games-lib = { };
  users.users.beatrice.extraGroups = [ "games-lib" "gamemode" "render" ];
  users.users.gaming = {
    isNormalUser = true;
    description = "Gaming";
    # Reuse the existing password file without copying a secret into the store.
    hashedPasswordFile = lib.mkDefault config.users.users.beatrice.hashedPasswordFile;
    extraGroups = [ "games-lib" "gamemode" "video" "render" ];
  };

  # Persistence entries live in impermanence.nix: the wrapper's `types.attrs`
  # option shallow-merges definitions, so a second directories list is lost.
  assertions = [
    {
      assertion = lib.any (mount:
        mount.where == "/home/gaming"
        && mount.what == "/persistent/home/gaming"
        && lib.elem "bind" (lib.splitString "," mount.options)
      ) config.systemd.mounts;
      message = "REVA gaming home must be bind-mounted from /persistent/home/gaming.";
    }
    {
      assertion = lib.any (mount:
        mount.where == "/var/lib/plasmalogin"
        && mount.what == "/persistent/var/lib/plasmalogin"
        && lib.elem "bind" (lib.splitString "," mount.options)
      ) config.systemd.mounts;
      message = "REVA Plasma Login state must be persisted alongside gaming's default session.";
    }
  ];

  # The distro's global Plasma preselection wins over per-user state when the
  # greeter first opens. Let it select the remembered session for each user.
  services.displayManager.plasma-login-manager.settings.Greeter.PreselectedSession = "";

  # Set gaming's default on both switch and daemon startup, including repairing
  # a Plasma session recorded before these defaults were initialized. Preserve
  # every other user's choice; beatrice gets Plasma only if no choice exists.
  system.activationScripts.gamingDefaultSession = {
    deps = [ "users" "groups" "createPersistentStorageDirs" ];
    text = "${initializeGamingSession}/bin/initialize-gaming-session /persistent/var/lib/plasmalogin";
  };
  systemd.services.plasmalogin.preStart =
    "${initializeGamingSession}/bin/initialize-gaming-session /var/lib/plasmalogin";

  programs.steam = {
    enable = true;
    # Remote Play 的 Wayland 采集只有带 -pipewire 启动时才会走
    # xdg-desktop-portal + PipeWire；否则回落到抓 X11 根窗口，在
    # Wayland/gamescope 会话里抓到的是空画面，客户端会报「捕获失败」。
    package = pkgs.steam.override { extraArgs = "-pipewire"; };
    gamescopeSession = {
      enable = true;
      args = [ "--hdr-enabled" ];
      env.ENABLE_GAMESCOPE_WSI = "1";
      # DXGI's Windows HDR state is shared by DX11 and DX12/Proton games.
      env.DXVK_HDR = "1";
      # 模块默认是 [ "-tenfoot" "-pipewire-dmabuf" ]，这里整体覆盖而非追加，
      # 所以要把默认值写全，再补上与桌面会话一致的 portal 采集开关。
      steamArgs = [ "-tenfoot" "-pipewire-dmabuf" "-pipewire" ];
    };
    # libextest aborts in XTestFakeRelativeMotionEvent in this Gamescope
    # session (observed Steam coredump). Keep Steam's normal controller support
    # without injecting this optional XTest-to-uinput compatibility library.
    extest.enable = false;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  # Expose the HDR-capable display to Vulkan/Proton clients in Gamescope.
  # The module installs both 64-bit and 32-bit WSI layers.
  programs.gamescope.enableWsi = true;
  programs.gamemode.enable = true;
  # Steam enables steam-hardware udev rules and uinput; standard USB/Bluetooth
  # controllers use the kernel drivers. Add model-specific drivers when needed.

  # KP70B uses 20dd:5160 when idle, 20bc:5160 for the active receiver, and
  # 20bc:515f when wired. BFM/XInput HID interfaces need explicit access too;
  # the generic joystick event-node ACL does not grant access to hidraw.
  # Give the active local session access without adding it to the input group.
  # This must run before 73-seat-late.rules applies the uaccess ACL.
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-gaming-kp70.rules" ''
      SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="20dd", ATTRS{idProduct}=="5160", TAG+="uaccess"
      SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="20bc", ATTRS{idProduct}=="515f", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="hidraw", KERNEL=="hidraw*", ATTRS{idVendor}=="20bc", ATTRS{idProduct}=="5160", MODE="0660", TAG+="uaccess"
    '')
  ];

  disko.devices.disk.main.content.partitions.root.content.content.subvolumes."@games-lib" = {
    mountpoint = "/games-lib";
    mountOptions = [ "compress-force=zstd:1" "noatime" ];
  };

  # Existing installations need the new subvolume before systemd mounts it.
  # Fresh disko installations have already created it. Never format the pool.
  fileSystems."/games-lib".options = [
    "x-systemd.requires=games-lib-subvolume.service"
  ];
  systemd.services.games-lib-subvolume = {
    description = "Ensure the Btrfs game library subvolume exists";
    requires = [ "btr_pool.mount" ];
    after = [ "btr_pool.mount" ];
    before = [ "games\\x2dlib.mount" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ! ${pkgs.btrfs-progs}/bin/btrfs subvolume show /btr_pool/@games-lib >/dev/null 2>&1; then
        ${pkgs.btrfs-progs}/bin/btrfs subvolume create /btr_pool/@games-lib
      fi
    '';
  };

  # The default ACL keeps new files writable by both library managers even when
  # a launcher uses umask 022. No recursive permission changes to existing games.
  systemd.tmpfiles.rules = lib.concatMap (directory: [
    "d ${directory} 2770 gaming games-lib -"
    "a ${directory} - - - - default:user::rwx,default:group::rwx,default:mask::rwx,default:other::---"
  ]) libraryDirectories;

  # Also order switch-time tmpfiles creation after the new mount, so the first
  # activation sets permissions on the subvolume rather than its mountpoint.
  systemd.services.systemd-tmpfiles-resetup.unitConfig.RequiresMountsFor = [ "/games-lib" ];
  systemd.services.systemd-tmpfiles-setup.unitConfig.RequiresMountsFor = [ "/games-lib" ];
}
