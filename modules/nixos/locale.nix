# modules/nixos/locale.nix
{ self, inputs, ... }: {
  flake.nixosModules.locale = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.locale; in
  {
    options.myNixOS.locale.enable = lib.mkEnableOption "locale and timezone";

    config = lib.mkIf cfg.enable {
      time.timeZone        = "Asia/Jerusalem";
      i18n.defaultLocale   = "en_IL";

      i18n.extraLocaleSettings = {
        LC_ADDRESS        = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT    = "en_US.UTF-8";
        LC_MONETARY       = "en_US.UTF-8";
        LC_NAME           = "en_US.UTF-8";
        LC_NUMERIC        = "en_US.UTF-8";
        LC_PAPER          = "en_US.UTF-8";
        LC_TELEPHONE      = "en_US.UTF-8";
        LC_TIME           = "en_US.UTF-8";
      };

      console.keyMap = "us";
    };
  };
}
