# modules/hosts/nixos/configuration.nix
#
# Host-specific configuration.  This file:
#   - toggles myNixOS.* feature flags to pull in the right modules
#   - sets any instance-specific options (service ports, hostName, etc.)
#   - handles overrides that must live at the host level (disabledModules, etc.)

{ config, inputs, ... }:
{
  # ── Overrides that must happen before modules are evaluated ─────────────────
  disabledModules = [ "services/web-apps/librechat.nix" ];

  imports = [
    # Use the unstable librechat module (stable one is disabled above)
    (inputs.nixpkgs-unstable + "/nixos/modules/services/web-apps/librechat.nix")
  ];

  # ── Host identity ────────────────────────────────────────────────────────────
  networking.hostName = "crazykazoo-dailydriver";

  # ── Nixpkgs global settings ──────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
    "librechat-0.8.0"
  ];

  # ── Feature enables ──────────────────────────────────────────────────────────
  # Each flag activates the corresponding module in modules/nixos/ or
  # modules/wrappedPrograms/.  Set to false to opt out of any feature.
  myNixOS = {
    boot.enable             = true;
    nvidia.enable           = true;
    power.enable            = true;
    networking.enable       = true;
    locale.enable           = true;
    desktop.enable          = true;
    hyprland.enable         = true;
    audio.enable            = true;
    bluetooth.enable        = true;
    zsh.enable              = true;
    gaming.enable           = true;
    docker.enable           = true;
    fonts.enable            = true;
    packages.enable         = true;
    nix.enable              = true;
    users.enable            = true;
    services.enable         = true;
    llamaCpp.enable         = true;
    equibop.enable          = true;
    noctalia.enable         = true;
    hardware.gigabyteLaptop.enable = true;
  };

  # ── Service instance configuration ───────────────────────────────────────────
  # The module definitions live in modules/services/; only instance-specific
  # values belong here.

  services.mcp-logic = {
    enable          = true;
    host            = "127.0.0.1";   # loopback only – safe default
    port            = 3100;
    allowedOrigins  = [ "*" ];
  };

  services.mcpo = {
    enable = true;
    port   = 3101;
    servers.logic = {
      url = "http://127.0.0.1:3100/sse";
    };
  };

  # ── Commented-out services (kept for reference) ───────────────────────────
  # services.librechat = {
  #   enable = true;
  #   credentialsFile = "/run/secrets/librechat.env";
  #   env.MONGO_URI = "mongodb://127.0.0.1:27017/LibreChat";
  # };
  # services.ferretdb = {
  #   enable = true;
  #   settings = {
  #     FERRETDB_HANDLER = "sqlite";
  #     FERRETDB_SQLITE_URL = "file:/var/lib/ferretdb/";
  #   };
  # };

  # ── State version ─────────────────────────────────────────────────────────────
  system.stateVersion = "25.11";
}
