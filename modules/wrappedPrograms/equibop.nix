# modules/wrappedPrograms/equibop.nix
#
# Equibop (Discord client) wrapper.
# No settings are configured here yet – add them inside `config` as needed.

{ self, inputs, ... }: {
  flake.nixosModules.equibop = { lib, config, pkgs, pkgsUnstable, ... }:
  let cfg = config.myNixOS.equibop; in
  {
    options.myNixOS.equibop = {
      enable = lib.mkEnableOption "equibop Discord client";
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgsUnstable.equibop ];

      # Future equibop settings go here, e.g.:
      # xdg.configFile."equibop/settings.json".source = ./equibop-settings.json;
    };
  };
}
