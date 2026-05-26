# modules/nixos/nix.nix
{ self, inputs, ... }: {
  flake.nixosModules.nix = { lib, config, pkgs, inputs, ... }:
  let cfg = config.myNixOS.nix; in
  {
    # The nix-index-database module must be imported unconditionally so
    # programs.nix-index-database.comma.enable is a valid option.
    imports = [ inputs.nix-index-database.nixosModules.nix-index ];

    options.myNixOS.nix.enable = lib.mkEnableOption "nix daemon settings";

    config = lib.mkIf cfg.enable {
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        # ezkea binary cache (for AAGL / anime game launchers)
        substituters       = [ "https://ezkea.cachix.org" ];
        trusted-public-keys = [
          "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        ];
      };

      programs.nix-ld = {
        enable    = true;
        # Only add the nvidia driver to the ld path on hosts that use nvidia.
        libraries = lib.optional config.myNixOS.nvidia.enable
          config.boot.kernelPackages.nvidia_x11;
      };

      programs.command-not-found.enable          = false;
      programs.nix-index.enable                  = true;
      programs.nix-index-database.comma.enable   = true;
    };
  };
}
