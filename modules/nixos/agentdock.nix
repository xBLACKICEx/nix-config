{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.services.agentdock;
  oauthEnvInit = pkgs.writeText "agentdock-oauth-env.py" ''
    import os, pathlib, re, secrets, tempfile

    target = pathlib.Path(${builtins.toJSON cfg.oauth.environmentFile})
    target.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(target.parent, 0o700)

    values = {}
    for path in (target.parent / "direct.env", target):
        if path.exists():
            for line in path.read_text().splitlines():
                key, separator, value = line.partition("=")
                if separator:
                    values[key] = value

    credentials = {}
    for key, size in (("AGENTDOCK_AUTH_TOKEN", 32),
                      ("AGENTDOCK_OAUTH_PASSWORD", 24),
                      ("AGENTDOCK_OAUTH_TOKEN_SECRET", 48)):
        value = values.get(key, "")
        credentials[key] = value if re.fullmatch(r"[a-f0-9]{%d}" % (size * 2), value) else secrets.token_hex(size)

    credentials.update(AGENTDOCK_SERVER_URL=${builtins.toJSON cfg.oauth.serverUrl},
                       AGENTDOCK_OAUTH_ENABLED="true",
                       AGENTDOCK_TRUSTED_PROXY_CIDRS="127.0.0.1/32")

    descriptor, temporary = tempfile.mkstemp(prefix=".oauth-env-", dir=target.parent)
    try:
        with os.fdopen(descriptor, "w") as handle:
            for key, value in credentials.items():
                handle.write(f"{key}={value}\n")
        os.chmod(temporary, 0o600)
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
  '';
  tunnelEnvFile = "${cfg.tunnel.runtimeDir}/agentdock.env";
  tunnelURLFile = "${cfg.tunnel.runtimeDir}/quick-tunnel-url";
  tunnelStart = pkgs.writeShellScript "agentdock-start-with-tunnel-token" ''
    set -eu
    set -a
    . ${lib.escapeShellArg tunnelEnvFile}
    set +a
    exec ${cfg.package}/bin/agentdock
  '';
  tunnelCloudflaredStart = pkgs.writeShellScript "agentdock-cloudflared-quick" ''
    set -euo pipefail
    umask 077
    runtime_dir=${lib.escapeShellArg cfg.tunnel.runtimeDir}
    url_file=${lib.escapeShellArg tunnelURLFile}
    ${pkgs.coreutils}/bin/mkdir -p "$runtime_dir"
    ${pkgs.coreutils}/bin/chmod 700 "$runtime_dir"
    # A stopped or failed tunnel must not advertise an old address.
    trap '${pkgs.coreutils}/bin/rm -f -- "$url_file"' EXIT
    trap 'exit 0' TERM INT
    ${pkgs.coreutils}/bin/rm -f -- "$url_file"
    ${cfg.tunnel.package}/bin/cloudflared tunnel --no-autoupdate --url http://${cfg.host}:${toString cfg.port} 2>&1 | while IFS= read -r line; do
      ${pkgs.coreutils}/bin/printf '%s\n' "$line"
      url=""
      if [[ "$line" =~ https://[-a-z0-9]+[.]trycloudflare[.]com ]]; then
        url="''${BASH_REMATCH[0]}"
      fi
      if [ -n "$url" ] && { [ ! -f "$url_file" ] || [ "$(<"$url_file")" != "$url" ]; }; then
        url_tmp="$(${pkgs.coreutils}/bin/mktemp "$runtime_dir/.quick-tunnel-url.XXXXXX")"
        ${pkgs.coreutils}/bin/printf '%s\n' "$url" > "$url_tmp"
        ${pkgs.coreutils}/bin/mv -- "$url_tmp" "$url_file"
      fi
    done
  '';
  tunnelOAuthRefresh = pkgs.writeShellScript "agentdock-refresh-oauth-origin" ''
    set -eu
    umask 077
    runtime_dir=${lib.escapeShellArg cfg.tunnel.runtimeDir}
    token_file=${lib.escapeShellArg tunnelEnvFile}
    url_file=${lib.escapeShellArg tunnelURLFile}
    # The path unit also fires when a tunnel exits and removes its address.
    if [ ! -s "$url_file" ]; then exit 0; fi
    url="$(${pkgs.coreutils}/bin/cat -- "$url_file")" || exit 0
    if [[ ! "$url" =~ ^https://[-a-z0-9]+[.]trycloudflare[.]com$ ]]; then
      echo "refusing invalid Quick Tunnel URL" >&2
      exit 1
    fi
    test -s "$token_file"
    # Read only generated credential keys as data, never source them as root.
    password="$(${pkgs.gnused}/bin/sed -n 's/^AGENTDOCK_OAUTH_PASSWORD=//p' "$token_file")"
    secret="$(${pkgs.gnused}/bin/sed -n 's/^AGENTDOCK_OAUTH_TOKEN_SECRET=//p' "$token_file")"
    if [[ ! "$password" =~ ^[a-f0-9]{48}$ ]]; then
      password="$(${pkgs.openssl}/bin/openssl rand -hex 24)"
    fi
    if [[ ! "$secret" =~ ^[a-f0-9]{96}$ ]]; then
      secret="$(${pkgs.openssl}/bin/openssl rand -hex 48)"
    fi
    tmp="$(${pkgs.coreutils}/bin/mktemp "$runtime_dir/.agentdock.env.XXXXXX")"
    trap '${pkgs.coreutils}/bin/rm -f -- "$tmp"' EXIT
    ${pkgs.gnused}/bin/sed -E '/^AGENTDOCK_(SERVER_URL|OAUTH_ENABLED|OAUTH_PASSWORD|OAUTH_TOKEN_SECRET)=/d' "$token_file" > "$tmp"
    ${pkgs.coreutils}/bin/printf 'AGENTDOCK_SERVER_URL=%s\n' "$url" >> "$tmp"
    ${pkgs.coreutils}/bin/printf '%s\n' 'AGENTDOCK_OAUTH_ENABLED=true' >> "$tmp"
    ${pkgs.coreutils}/bin/printf 'AGENTDOCK_OAUTH_PASSWORD=%s\n' "$password" >> "$tmp"
    ${pkgs.coreutils}/bin/printf 'AGENTDOCK_OAUTH_TOKEN_SECRET=%s\n' "$secret" >> "$tmp"
    # Duplicate path events must not restart the core or invalidate logins.
    if ${pkgs.diffutils}/bin/cmp -s "$tmp" "$token_file"; then exit 0; fi
    ${pkgs.coreutils}/bin/chmod 600 "$tmp"
    ${pkgs.coreutils}/bin/mv "$tmp" "$token_file"
    ${pkgs.coreutils}/bin/chown ${lib.escapeShellArg cfg.user} "$token_file"
    ${pkgs.systemd}/bin/systemctl restart agentdock.service
  '';
in
{
  options.services.agentdock = {
    enable = mkEnableOption "the AgentDock MCP runtime";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../pkgs/agentdock.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ../../pkgs/agentdock.nix { }";
      description = "AgentDock package to run.";
    };

    user = mkOption {
      type = types.str;
      default = "michiha";
      description = "Unprivileged account that owns AgentDock state and executes its tools.";
    };

    group = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Optional group for the AgentDock service. By default systemd uses the service user's primary group.";
    };

    home = mkOption {
      type = types.str;
      default = "/home/${cfg.user}";
      defaultText = lib.literalExpression "\"/home/\${config.services.agentdock.user}\"";
      description = "Home directory of the AgentDock service user.";
    };

    stateDir = mkOption {
      type = types.str;
      default = "${cfg.home}/.agentdock";
      defaultText = lib.literalExpression "\"\${config.services.agentdock.home}/.agentdock\"";
      description = "Writable directory for AgentDock state, installed Skills, and task data.";
    };

    workspace = mkOption {
      type = types.str;
      default = "${cfg.home}/AgentDock";
      defaultText = lib.literalExpression "\"\${config.services.agentdock.home}/AgentDock\"";
      description = "Default directory supplied to AgentDock tools; it is not an access-control boundary.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listening address. Keep this loopback default unless HTTPS and authentication are configured.";
    };

    port = mkOption {
      type = types.port;
      default = 8765;
      description = "TCP port for the AgentDock MCP endpoint.";
    };

    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warn" "error" ];
      default = "info";
      description = "AgentDock log level.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/agenix/agentdock-env";
      description = "Optional systemd environment file for secrets and advanced AGENTDOCK_* settings. Put auth or OAuth secrets here, never in the Nix store.";
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional non-secret environment variables passed to AgentDock.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Extra commands available to commands that AgentDock runs.";
    };

    oauth = {
      enable = mkEnableOption "OAuth for a fixed public AgentDock origin";

      serverUrl = mkOption {
        type = types.str;
        example = "https://mcp.example.com";
        description = "Public HTTPS origin used by AgentDock OAuth metadata. It must not include a path.";
      };

      environmentFile = mkOption {
        type = types.str;
        default = "${cfg.home}/.local/state/agentdock/oauth.env";
        defaultText = lib.literalExpression ''"\${config.services.agentdock.home}/.local/state/agentdock/oauth.env"'';
        description = "Runtime-generated OAuth and bearer credentials. This file is never copied into the Nix store.";
      };
    };

    tunnel = {
      enable = mkEnableOption "a temporary Cloudflare Quick Tunnel for AgentDock";

      runtimeDir = mkOption {
        type = types.str;
        default = "${cfg.home}/.local/state/agentdock";
        defaultText = lib.literalExpression "\"\${config.services.agentdock.home}/.local/state/agentdock\"";
        description = "User-owned directory that holds generated AgentDock Bearer and OAuth credentials for the temporary tunnel.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.cloudflared;
        description = "cloudflared package used to establish the temporary Quick Tunnel.";
      };
    };

    browser = {
      enable = mkEnableOption "AgentDock browser automation" // { default = true; };

      package = mkOption {
        type = types.package;
        default = pkgs.chromium;
        description = "Chromium-compatible browser to launch for browser automation.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != "";
        message = "services.agentdock.user must not be empty.";
      }
      {
        assertion = !cfg.tunnel.enable || cfg.host == "127.0.0.1";
        message = "services.agentdock.tunnel.enable requires services.agentdock.host = \"127.0.0.1\" so AgentDock remains private behind the tunnel.";
      }
      {
        assertion = !(cfg.oauth.enable && cfg.tunnel.enable);
        message = "services.agentdock.oauth and services.agentdock.tunnel are mutually exclusive.";
      }
      {
        assertion = !cfg.oauth.enable || cfg.host == "127.0.0.1";
        message = "services.agentdock.oauth.enable requires services.agentdock.host = \"127.0.0.1\" so AgentDock remains private behind the reverse proxy.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.agentdock = {
      description = "AgentDock MCP runtime";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ] ++ lib.optional cfg.oauth.enable "agentdock-oauth-env.service";
      wants = [ "network-online.target" ];
      requires = lib.optional cfg.oauth.enable "agentdock-oauth-env.service";

      path = with pkgs; [
        bash
        coreutils
        findutils
        gnugrep
        gnused
        git
        openssh
        curl
        wget
        jq
        ripgrep
        fd
        gnutar
        gzip
        unzip
        nix
      ] ++ lib.optional cfg.tunnel.enable openssl ++ cfg.extraPackages;

      environment = {
        HOME = cfg.home;
        AGENTDOCK_HOME = cfg.stateDir;
        AGENTDOCK_DEFAULT_DIR = cfg.workspace;
        AGENTDOCK_HOST = cfg.host;
        AGENTDOCK_PORT = toString cfg.port;
        AGENTDOCK_LOG_LEVEL = cfg.logLevel;
        AGENTDOCK_BROWSER_ENABLED = lib.boolToString cfg.browser.enable;
      } // lib.optionalAttrs cfg.browser.enable {
        AGENTDOCK_BROWSER_EXECUTABLE_PATH = "${cfg.browser.package}/bin/chromium";
      } // cfg.extraEnvironment;

      serviceConfig = {
        User = cfg.user;
        # AgentDock creates cfg.workspace during its bootstrap. systemd changes
        # directory before ExecStartPre, so it must start from the existing
        # service home rather than the initially absent workspace.
        WorkingDirectory = cfg.home;
        UMask = "0077";
        # The OAuth preparation unit creates its file before this service starts.
        # Quick tunnels still use an optional file and source it in tunnelStart.
        EnvironmentFile = lib.optional cfg.oauth.enable cfg.oauth.environmentFile
          ++ lib.optional cfg.tunnel.enable "-${tunnelEnvFile}"
          ++ lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStartPre = lib.optional cfg.tunnel.enable
          (pkgs.writeShellScript "agentdock-init-tunnel-token" ''
            set -eu
            umask 077
            runtime_dir=${lib.escapeShellArg cfg.tunnel.runtimeDir}
            token_file=${lib.escapeShellArg tunnelEnvFile}
            ${pkgs.coreutils}/bin/mkdir -p "$runtime_dir"
            ${pkgs.coreutils}/bin/chmod 700 "$runtime_dir"
            if ! ${pkgs.gnugrep}/bin/grep -qE '^AGENTDOCK_AUTH_TOKEN=[a-f0-9]{64}$' "$token_file" 2>/dev/null; then
              # Also repair the legacy initializer's literal backslash-n suffix.
              # Preserve OAuth settings when replacing a malformed Bearer token.
              token="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
              tmp="$(${pkgs.coreutils}/bin/mktemp "$runtime_dir/.agentdock-init.XXXXXX")"
              trap '${pkgs.coreutils}/bin/rm -f -- "$tmp"' EXIT
              if [ -f "$token_file" ]; then
                ${pkgs.gnused}/bin/sed '/^AGENTDOCK_AUTH_TOKEN=/d' "$token_file" > "$tmp"
              fi
              ${pkgs.coreutils}/bin/printf 'AGENTDOCK_AUTH_TOKEN=%s\n' "$token" >> "$tmp"
              ${pkgs.coreutils}/bin/mv -- "$tmp" "$token_file"
            fi
            ${pkgs.coreutils}/bin/chmod 600 "$token_file"
          '') ++ [
          "${cfg.package}/bin/agentdock skill bootstrap --bundle ${cfg.package}/share/agentdock/core-skills"
        ];
        ExecStart = if cfg.tunnel.enable then "${tunnelStart}" else "${cfg.package}/bin/agentdock";
        Restart = "on-failure";
        RestartSec = 3;
      } // lib.optionalAttrs (cfg.group != null) {
        Group = cfg.group;
      };
    };

    systemd.services.agentdock-oauth-env = mkIf cfg.oauth.enable {
      description = "Prepare AgentDock OAuth credentials";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        UMask = "0077";
        ExecStart = "${pkgs.python3}/bin/python3 ${oauthEnvInit}";
      } // lib.optionalAttrs (cfg.group != null) {
        Group = cfg.group;
      };
    };

    systemd.services.agentdock-cloudflared = mkIf cfg.tunnel.enable {
      description = "AgentDock temporary Cloudflare Quick Tunnel";
      wantedBy = [ "multi-user.target" ];
      # Requires propagates core restarts into the tunnel. Updating the OAuth
      # origin would then destroy that very URL and provision another forever.
      after = [ "agentdock.service" "agentdock-oauth-url.path" "network-online.target" ];
      wants = [ "agentdock.service" "agentdock-oauth-url.path" "network-online.target" ];
      startLimitIntervalSec = 900;
      startLimitBurst = 2;

      serviceConfig = {
        User = cfg.user;
        WorkingDirectory = cfg.home;
        UMask = "0077";
        ExecStart = "${tunnelCloudflaredStart}";
        Restart = "on-failure";
        # Cloudflare rate-limits account-less Quick Tunnel provisioning.
        # A failed connection must not turn into a fast retry loop.
        RestartSec = "5min";
      } // lib.optionalAttrs (cfg.group != null) {
        Group = cfg.group;
      };
    };

    systemd.paths.agentdock-oauth-url = mkIf cfg.tunnel.enable {
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathChanged = tunnelURLFile;
        Unit = "agentdock-oauth-url.service";
      };
    };

    systemd.services.agentdock-oauth-url = mkIf cfg.tunnel.enable {
      description = "Update AgentDock OAuth origin after a Quick Tunnel URL change";
      after = [ "agentdock-cloudflared.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${tunnelOAuthRefresh}";
      };
    };
  };
}
