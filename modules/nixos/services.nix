# modules/nixos/services.nix
{ self, inputs, ... }: {
  flake.nixosModules.services = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.services; in
  {
    options.myNixOS.services.enable = lib.mkEnableOption "miscellaneous services (open-webui, timekpr)";

    config = lib.mkIf cfg.enable {
      services.open-webui.enable = true;
      services.timekpr.enable    = true;
      programs.firefox.enable    = false;
    };
  };
}
