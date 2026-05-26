# modules/nixos/networking.nix
{ self, inputs, ... }: {
  flake.nixosModules.networking = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.networking; in
  {
    options.myNixOS.networking.enable = lib.mkEnableOption "networking, avahi, ADB, KDE Connect";

    config = lib.mkIf cfg.enable {
      networking.networkmanager.enable = true;
      networking.firewall.enable       = false;

      services.avahi = {
        enable  = true;
        publish = {
          enable       = true;
          userServices = true;
        };
      };

      programs.adb.enable        = true;
      programs.kdeconnect.enable = true;
    };
  };
}
