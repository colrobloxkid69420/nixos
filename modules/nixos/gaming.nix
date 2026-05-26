# modules/nixos/gaming.nix
{ self, inputs, ... }: {
  flake.nixosModules.gaming = { lib, config, pkgs, inputs, ... }:
  let cfg = config.myNixOS.gaming; in
  {
    # aagl's nixosModule must be imported unconditionally so its options are
    # defined; the individual launchers are only enabled inside mkIf below.
    imports = [ inputs.aagl.nixosModules.default ];

    options.myNixOS.gaming.enable = lib.mkEnableOption "gaming (Steam + AAGL launchers)";

    config = lib.mkIf cfg.enable {
      # Pull in the aagl binary cache
      nix.settings = inputs.aagl.nixConfig;

      programs.steam = {
        enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };

      # ── AAGL launchers ────────────────────────────────────────────────────
      programs.anime-game-launcher.enable       = false;
      programs.anime-games-launcher.enable      = false;
      programs.honkers-railway-launcher.enable  = true;
      programs.honkers-launcher.enable          = true;
      programs.wavey-launcher.enable            = false;
      programs.sleepy-launcher.enable           = false;
    };
  };
}
