# modules/nixos/nvidia.nix
{ self, inputs, ... }: {
  flake.nixosModules.nvidia = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.nvidia; in
  {
    options.myNixOS.nvidia.enable = lib.mkEnableOption "NVIDIA GPU (prime offload)";

    config = lib.mkIf cfg.enable {
      hardware.graphics.enable = true;

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.latest;
        open    = true;
        prime = {
          offload = {
            enable          = true;
            enableOffloadCmd = true;
          };
          intelBusId  = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
    };
  };
}
