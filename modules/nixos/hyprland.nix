# modules/nixos/hyprland.nix
{ self, inputs, ... }: {
  flake.nixosModules.hyprland = { lib, config, pkgs, pkgsUnstable, ... }:
  let cfg = config.myNixOS.hyprland; in
  {
    options.myNixOS.hyprland.enable = lib.mkEnableOption "Hyprland (unstable)";

    config = lib.mkIf cfg.enable {
      programs.hyprland = {
        enable    = true;
        package   = pkgsUnstable.hyprland;
        withUWSM  = false;
        xwayland.enable = true;
      };
    };
  };
}
