# modules/hardware/gigabyte-laptop.nix
{ self, inputs, ... }: {
  flake.nixosModules.gigabyte-laptop = { lib, config, pkgs, ... }:
  {
    options.myNixOS.hardware.gigabyteLaptop.enable =
      lib.mkEnableOption "Gigabyte/Aorus laptop WMI kernel module";

    config = lib.mkIf config.myNixOS.hardware.gigabyteLaptop.enable {
      boot.extraModulePackages = [
        (config.boot.kernelPackages.callPackage ./_gigabyte_laptop { })
      ];
      boot.kernelModules                   = [ "aorus-laptop" ];
      boot.initrd.availableKernelModules   = [ "aorus-laptop" ];
    };
  };
}
