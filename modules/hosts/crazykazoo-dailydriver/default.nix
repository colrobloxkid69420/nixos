# modules/hosts/crazykazoo-dailydriver/default.nix

{ self, inputs, ... }:
let
  system = "x86_64-linux";

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  flake.nixosConfigurations.crazykazoo-dailydriver = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs pkgsUnstable;
      flakeInputs = inputs;
    };

    modules =
      [
        ./_configuration.nix
        ./_hardware-configuration.nix
      ]
      ++ (builtins.attrValues self.nixosModules);
  };
}
