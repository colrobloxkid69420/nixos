# modules/nixos/boot.nix
{ self, inputs, ... }: {
  flake.nixosModules.boot = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.boot; in
  {
    options.myNixOS.boot.enable = lib.mkEnableOption "boot loader and kernel";

    config = lib.mkIf cfg.enable {
      boot.loader.systemd-boot.enable    = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages                = pkgs.linuxPackages;
    };
  };
}
