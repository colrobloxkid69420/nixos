# modules/nixos/desktop.nix
{ self, inputs, ... }: {
  flake.nixosModules.desktop = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.desktop; in
  {
    options.myNixOS.desktop.enable = lib.mkEnableOption "KDE Plasma 6 desktop";

    config = lib.mkIf cfg.enable {
      services.xserver.enable = true;

      services.displayManager.sddm.enable     = true;
      services.desktopManager.plasma6.enable  = true;

      services.xserver.xkb = {
        layout  = "us,il";
        variant = "";
      };

      services.printing.enable = true;

      # GNOME support services (used by GNOME Calendar, etc. even under KDE)
      programs.dconf.enable                         = true;
      services.gnome.evolution-data-server.enable   = true;
      services.gnome.gnome-online-accounts.enable   = true;
      services.gnome.gnome-keyring.enable           = true;
    };
  };
}
