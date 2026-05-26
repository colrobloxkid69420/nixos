# modules/nixos/users.nix
{ self, inputs, ... }: {
  flake.nixosModules.users = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.users; in
  {
    options.myNixOS.users.enable = lib.mkEnableOption "user accounts";

    config = lib.mkIf cfg.enable {
      users.users.crazykazoo = {
        isNormalUser = true;
        description  = "Yoav Cohen";
        extraGroups  = [ "networkmanager" "wheel" "docker" ];
        shell        = pkgs.zsh;
        packages     = with pkgs; [
          kdePackages.kate
          # thunderbird
        ];
      };
    };
  };
}
