# modules/wrappedPrograms/noctalia.nix
#
# Noctalia shell + companion tools.

{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { lib, config, pkgs, inputs, ... }:
  let cfg = config.myNixOS.noctalia; in
  {
    options.myNixOS.noctalia.enable = lib.mkEnableOption "noctalia shell";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        grim
        imagemagick_light
        wl-clipboard-rs
        satty
        xdg-utils
        jq
        wf-recorder
      ];
    };
  };
}
