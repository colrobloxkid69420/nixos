# modules/nixos/audio.nix
{ self, inputs, ... }: {
  flake.nixosModules.audio = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.audio; in
  {
    options.myNixOS.audio.enable = lib.mkEnableOption "PipeWire audio";

    config = lib.mkIf cfg.enable {
      services.pulseaudio.enable = false;   # must be off when PipeWire is used
      security.rtkit.enable      = true;

      services.pipewire = {
        enable           = true;
        alsa.enable      = true;
        alsa.support32Bit = true;
        pulse.enable     = true;
        # jack.enable     = true;   # uncomment if needed
      };
    };
  };
}
