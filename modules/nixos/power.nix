# modules/nixos/power.nix
{ self, inputs, ... }: {
  flake.nixosModules.power = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.power; in
  {
    options.myNixOS.power.enable = lib.mkEnableOption "power management (auto-cpufreq)";

    config = lib.mkIf cfg.enable {
      services.power-profiles-daemon.enable = false;   # conflicts with auto-cpufreq
      services.auto-cpufreq = {
        enable   = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo    = "never";
          };
          charger = {
            governor = "performance";
            turbo    = "auto";
          };
        };
      };
    };
  };
}
