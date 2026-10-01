{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.core.impermanence;
  # 文件的 user/group/mode 是本封装扩展，不能传给上游 impermanence。
  stripFilePermissions = scope: scope // optionalAttrs (scope ? files) {
    files = map (file: if isAttrs file then removeAttrs file [ "user" "group" "mode" ] else file) scope.files;
  };
  mkEntries = home: defaultUser: defaultGroup: scope:
    let
      mkEntry = kind: entry:
        let
          explicit = isAttrs entry;
          spec = if explicit then entry else { ${kind} = entry; };
          user = spec.user or defaultUser;
        in {
          path = "${toString (spec.persistentStoragePath or (scope.persistentStoragePath or "/persistent"))}${home}/${removePrefix "/" spec.${kind}}";
          inherit user;
          group = spec.group or defaultGroup;
          mode = spec.mode or null;
        };
      # 系统字符串条目没有声明权限；不要把服务维护的目录重置为 root。
      managed = entries: filter (entry: defaultUser != null || (isAttrs entry &&
        (entry ? user || entry ? group || entry ? mode))) entries;
    in
      map (mkEntry "directory") (managed (scope.directories or [ ]))
      ++ map (mkEntry "file") (managed (scope.files or [ ]));
  systemEntries = mkEntries "" null null cfg.persistence;
  userEntries = concatLists (mapAttrsToList (name: scope:
    mkEntries config.users.users.${name}.home name config.users.users.${name}.group scope
  ) cfg.users);
  hmEntries = concatLists (mapAttrsToList (_: hm:
    let
      fileOverrides = concatLists (mapAttrsToList (storage: scope:
        mkEntries hm.home.homeDirectory hm.home.username config.users.users.${hm.home.username}.group
          (removeAttrs scope [ "directories" ] // { persistentStoragePath = scope.persistentStoragePath or storage; })
      ) (hm.impermanence.persistence or { }));
    in
    if !(hm.impermanence.enforcePermissions or true) then [ ] else
    concatLists (map (scope:
      if !scope.enable then [ ] else
      map (dir: {
        path = "${toString dir.persistentStoragePath}${dir.dirPath}";
        inherit (dir) user mode;
        group = if dir.group == null then config.users.users.${dir.user}.group else dir.group;
      }) scope.directories
      ++ map (file:
        let path = "${toString file.persistentStoragePath}${file.filePath}";
        in findFirst (entry: entry.path == path) {
          inherit path;
          user = hm.home.username;
          group = config.users.users.${hm.home.username}.group;
          mode = null;
        } fileOverrides
      ) scope.files
    ) (attrValues (hm.home.persistence or { })))
  ) (config.home-manager.users or { }));
  permissionsScript = pkgs.writeShellScript "persistence-enforce-permissions" (
    ''
      set -euo pipefail
      status=0
      apply_permissions() {
        local path="$1" owner="$2" mode="$3"
        [ -e "$path" ] || return 0
        if [ -n "$owner" ] && ! ${pkgs.coreutils}/bin/chown -- "$owner" "$path"; then
          printf 'impermanence: failed to set owner %s on %s\n' "$owner" "$path" >&2
          return 1
        fi
        if [ -n "$mode" ] && ! ${pkgs.coreutils}/bin/chmod -- "$mode" "$path"; then
          printf 'impermanence: failed to set mode %s on %s\n' "$mode" "$path" >&2
          return 1
        fi
        return 0
      }
    '' + concatMapStrings (entry:
      let
        path = escapeShellArg entry.path;
        owner = optionalString (entry.user != null) entry.user
          + optionalString (entry.group != null) ":${entry.group}";
      in ''
        if ! apply_permissions ${path} ${escapeShellArg owner} ${escapeShellArg (if entry.mode == null then "" else entry.mode)}; then
          status=1
        fi
      ''
    ) (optionals (cfg.persistence.enable or true) (systemEntries ++ userEntries) ++ hmEntries)
    + "exit \"$status\"\n"
  );
in
{
  options.core.impermanence = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "是否启用 impermanence 模块";
    };

    enforcePermissions = mkOption {
      type = types.bool;
      default = true;
      description = ''
        启动和切换配置时自动校正已有持久化目录及文件的 user/group/mode。
        系统条目仅应用显式声明的权限；用户条目默认校正属主和主组。
        不递归修改目录内容。文件条目可额外声明 user/group/mode。
      '';
    };

    persistence = mkOption {
      type = types.attrs;
      default = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/etc/shadow"
          "/etc/passwd"
          "/etc/group"
          "/etc/ssh"

          "/root"
          "/var"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
      description = "持久化目录和文件配置";
    };

    users = mkOption {
      type = types.attrs;
      default = { };
      description = "需要持久化的用户信息";
    };
  };

  config = mkIf cfg.enable (mkMerge [ {
    environment.systemPackages = [ pkgs.ncdu ];
    systemd.services.nix-daemon = {
      environment = {
        # 指定临时文件的位置
        TMPDIR = "/var/cache/nix";
      };
      serviceConfig = {
        # 在 Nix Daemon 启动时自动创建 /var/cache/nix
        CacheDirectory = "nix";
      };
    };
    environment.variables.NIX_REMOTE = "daemon";

    environment.persistence."/persistent" = (stripFilePermissions cfg.persistence // {
      users = mapAttrs (_: stripFilePermissions) cfg.users;
    });
  }
  (mkIf cfg.enforcePermissions {
    # 在上游从持久化源复制权限前校正已有条目。
    system.activationScripts.enforcePersistencePermissions = {
      deps = [ "users" "groups" ];
      text = "${permissionsScript}";
    };
    system.activationScripts.createPersistentStorageDirs.deps = [ "enforcePersistencePermissions" ];
    # 文件首次持久化后再校正一次，覆盖新创建的文件。
    system.activationScripts.enforcePersistedFilePermissions = {
      deps = [ "persist-files" ];
      text = "${permissionsScript}";
    };
  })
  (optionalAttrs (options ? home-manager) {
    home-manager.sharedModules = [ ../../home-manager/impermanence.nix ];
  }) ]);
}
