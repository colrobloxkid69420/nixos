# modules/nixos/bluetooth.nix
{ self, inputs, ... }: {
  flake.nixosModules.bluetooth = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.bluetooth; in
  {
    options.myNixOS.bluetooth.enable = lib.mkEnableOption "Bluetooth";

    config = lib.mkIf cfg.enable {
      hardware.bluetooth = {
        enable       = true;
        powerOnBoot  = true;
        settings = {
          General = {
            # Show battery charge of connected devices where supported.
            Experimental     = true;
            # Faster reconnection at the cost of slightly more power draw.
            FastConnectable  = true;
          };
          Policy.AutoEnable = true;
        };
      };

      services.blueman.enable = true;
    };
  };
}
