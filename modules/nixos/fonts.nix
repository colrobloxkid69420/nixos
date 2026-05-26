# modules/nixos/fonts.nix
{ self, inputs, ... }: {
  flake.nixosModules.fonts = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.fonts; in
  {
    options.myNixOS.fonts.enable = lib.mkEnableOption "fonts";

    config = lib.mkIf cfg.enable {
      fonts.packages = with pkgs; [
        corefonts
        nerd-fonts.jetbrains-mono
        wineWowPackages.fonts
      ];

      fonts.fontconfig.defaultFonts = {
        serif = [ "Lexend" "PloniMLv2AAA-Regular" ];
      };
    };
  };
}
