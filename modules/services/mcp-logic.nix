# modules/services/mcp-logic.nix
#
# Defines the services.mcp-logic NixOS option set and the systemd service that
# runs mcp-logic behind mcp-proxy (SSE/HTTP transport).
# Instance configuration (host, port, …) lives in modules/hosts/nixos/configuration.nix.

{ self, inputs, ... }: {
  flake.nixosModules.mcp-logic = { config, lib, pkgs, pkgsUnstable, inputs, ... }:
  with lib;
  let
    cfg = config.services.mcp-logic;

    mcpLogic = pkgs.python3Packages.buildPythonApplication {
      pname    = "mcp-logic";
      version  = "unstable";
      src      = inputs.mcp-logic-src;
      pyproject = true;
      build-system = with pkgs.python3Packages; [ hatchling ];
      dependencies = with pkgs.python3Packages; [
        mcp fastapi uvicorn pydantic pytest-asyncio
      ];
      doCheck = false;
    };

    # mcp-proxy requires mcp>=1.27.1 / uvicorn>=0.47.0 — only in unstable.
    py = pkgsUnstable.python3Packages;

    mcpProxy = py.buildPythonApplication {
      pname    = "mcp-proxy";
      version  = "unstable";
      src      = inputs.mcp-proxy-src;
      pyproject = true;
      pythonRelaxDeps = true;
      build-system = with py; [ setuptools ];
      dependencies = with py; [
        mcp uvicorn anyio click httpx httpx-sse
        (httpx-auth.overridePythonAttrs (_: { doCheck = false; }))
      ];
      doCheck = false;
    };

    defaultProverPath = "${pkgs.prover9}/bin/";
  in
  {
    # ── Options ────────────────────────────────────────────────────────────────
    options.services.mcp-logic = {
      enable = mkEnableOption "MCP Logic HTTP/SSE server";

      proverPath = mkOption {
        type    = types.str;
        default = defaultProverPath;
        description = "Path to the prover9 binary directory.";
      };

      host = mkOption {
        type    = types.str;
        default = "127.0.0.1";
        description = ''
          Address to bind to.
          Use "0.0.0.0" to expose on all interfaces (trusted networks only).
        '';
      };

      port = mkOption {
        type    = types.port;
        default = 3100;
        description = "TCP port the HTTP server listens on.";
      };

      logLevel = mkOption {
        type    = types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL" ];
        default = "INFO";
        description = "Log verbosity for mcp_logic.";
      };

      user  = mkOption { type = types.str; default = "mcp-logic"; };
      group = mkOption { type = types.str; default = "mcp-logic"; };

      openFirewall = mkOption {
        type    = types.bool;
        default = false;
        description = "Open the port in the firewall.";
      };

      allowedOrigins = mkOption {
        type    = types.listOf types.str;
        default = [ "*" ];
        example = [ "http://localhost:3000" "app://." ];
        description = ''
          Origins allowed via CORS (passed as --allow-origin to mcp-proxy).
          Set to [ "*" ] to allow all origins (safe for localhost-only binding).
        '';
      };

      extraArgs = mkOption {
        type    = types.listOf types.str;
        default = [];
        description = "Extra arguments appended to mcp_logic.";
      };
    };

    # ── Implementation ─────────────────────────────────────────────────────────
    config = mkIf cfg.enable {
      users.users.${cfg.user} = {
        isSystemUser = true;
        group        = cfg.group;
        description  = "MCP Logic service account";
      };
      users.groups.${cfg.group} = {};

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      systemd.services.mcp-logic = {
        description   = "MCP Logic HTTP/SSE server (via mcp-proxy)";
        documentation = [ "https://github.com/angrysky56/mcp-logic" ];
        wantedBy      = [ "multi-user.target" ];
        after         = [ "network.target" ];

        serviceConfig = {
          Type  = "simple";
          User  = cfg.user;
          Group = cfg.group;

          ExecStart = lib.escapeShellArgs (
            [ "${mcpProxy}/bin/mcp-proxy"
              "--host" cfg.host
              "--port" (toString cfg.port)
            ]
            ++ lib.concatMap (o: [ "--allow-origin" o ]) cfg.allowedOrigins
            ++ [ "--"
              "${mcpLogic}/bin/mcp_logic"
              "--prover-path" cfg.proverPath
              "--log-level"   cfg.logLevel
            ] ++ cfg.extraArgs
          );

          Restart    = "on-failure";
          RestartSec = "5s";

          NoNewPrivileges        = true;
          PrivateTmp             = true;
          ProtectSystem          = "strict";
          ProtectHome            = true;
          ProtectKernelTunables  = true;
          ProtectKernelModules   = true;
          ProtectControlGroups   = true;
          RestrictNamespaces     = true;
          LockPersonality        = true;
          MemoryDenyWriteExecute = false;   # Python needs this
          RestrictRealtime       = true;
          RestrictSUIDSGID       = true;
          RemoveIPC              = true;
        };
      };
    };
  };
}
