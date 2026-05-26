# modules/services/mcpo.nix
#
# Defines the services.mcpo NixOS option set (MCP-to-OpenAPI proxy).
# Instance configuration lives in modules/hosts/nixos/configuration.nix.

{ self, inputs, ... }: {
  flake.nixosModules.mcpo = { config, lib, pkgs, pkgsUnstable, inputs, ... }:
  with lib;
  let
    cfg = config.services.mcpo;
    py  = pkgsUnstable.python3Packages;

    mcpo = py.buildPythonApplication {
      pname    = "mcpo";
      version  = "unstable";
      src      = inputs.mcpo-src;
      pyproject = true;
      pythonRelaxDeps = true;
      build-system = with py; [ setuptools hatchling ];
      dependencies = with py; [
        fastapi uvicorn httpx httpx-sse pydantic anyio click
        pyyaml mcp passlib typer watchdog
      ];
      doCheck = false;
    };
  in
  {
    # ── Options ────────────────────────────────────────────────────────────────
    options.services.mcpo = {
      enable = mkEnableOption "mcpo MCP-to-OpenAPI proxy";

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
        default = 8000;
        description = "TCP port mcpo listens on.";
      };

      apiKey = mkOption {
        type    = types.nullOr types.str;
        default = null;
        description = ''
          Optional API key to protect the mcpo endpoint.
          Passed as --api-key. Leave null to disable authentication.
        '';
      };

      configFile = mkOption {
        type    = types.nullOr types.path;
        default = null;
        example = "/etc/mcpo/config.json";
        description = ''
          Path to a mcpo JSON config file.
          Mutually exclusive with the inline `servers` option.
        '';
      };

      servers = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            url = mkOption {
              type    = types.nullOr types.str;
              default = null;
              description = "SSE URL for a remote MCP server (use instead of command).";
            };
            command = mkOption {
              type    = types.nullOr types.str;
              default = null;
              description = "Executable to launch as a stdio MCP server.";
            };
            args = mkOption {
              type    = types.listOf types.str;
              default = [];
              description = "Arguments for the command.";
            };
            env = mkOption {
              type    = types.attrsOf types.str;
              default = {};
              description = "Extra environment variables for the server process.";
            };
          };
        });
        default = {};
        description = ''
          Inline server definitions written to a generated config file.
          Each attribute name becomes the URL path prefix exposed by mcpo.
        '';
      };

      user  = mkOption { type = types.str; default = "mcpo"; };
      group = mkOption { type = types.str; default = "mcpo"; };

      openFirewall = mkOption {
        type    = types.bool;
        default = false;
        description = "Open the port in the firewall.";
      };

      extraArgs = mkOption {
        type    = types.listOf types.str;
        default = [];
        description = "Extra arguments appended to the mcpo invocation.";
      };
    };

    # ── Implementation ─────────────────────────────────────────────────────────
    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = !(cfg.configFile != null && cfg.servers != {});
          message   = "services.mcpo: set either configFile or servers, not both.";
        }
      ];

      users.users.${cfg.user} = {
        isSystemUser = true;
        group        = cfg.group;
        description  = "mcpo service account";
      };
      users.groups.${cfg.group} = {};

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      environment.etc."mcpo/config.json" = mkIf (cfg.servers != {}) {
        mode  = "0440";
        user  = cfg.user;
        group = cfg.group;
        text  = builtins.toJSON {
          mcpServers = mapAttrs (_name: srv:
            (optionalAttrs (srv.url     != null) { inherit (srv) url; })
            // (optionalAttrs (srv.command != null) { inherit (srv) command args; })
            // (optionalAttrs (srv.env    != {})    { inherit (srv) env; })
          ) cfg.servers;
        };
      };

      systemd.services.mcpo = {
        description   = "mcpo – MCP-to-OpenAPI proxy";
        documentation = [ "https://github.com/open-webui/mcpo" ];
        wantedBy      = [ "multi-user.target" ];
        after         = [
          "network.target"
          (mkIf config.services.mcp-logic.enable "mcp-logic.service")
        ];

        serviceConfig = {
          Type  = "simple";
          User  = cfg.user;
          Group = cfg.group;

          ExecStart = lib.escapeShellArgs (
            [ "${mcpo}/bin/mcpo"
              "--host" cfg.host
              "--port" (toString cfg.port)
            ]
            ++ lib.optionals (cfg.apiKey     != null)  [ "--api-key" cfg.apiKey ]
            ++ lib.optionals (cfg.configFile != null)  [ "--config"  cfg.configFile ]
            ++ lib.optionals (cfg.servers    != {})    [ "--config"  "/etc/mcpo/config.json" ]
            ++ cfg.extraArgs
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
