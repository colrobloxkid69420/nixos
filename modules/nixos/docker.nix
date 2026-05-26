# modules/nixos/docker.nix
{ self, inputs, ... }: {
  flake.nixosModules.docker = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.docker; in
  {
    options.myNixOS.docker.enable = lib.mkEnableOption "Docker + NVIDIA container toolkit";

    config = lib.mkIf cfg.enable {
      virtualisation.docker.enable              = true;
      hardware.nvidia-container-toolkit.enable  = true;
    };
  };
}
