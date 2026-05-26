# modules/hosts/server/default.nix

{ self, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = { inherit inputs; };

    modules =
      [
        # disko and preservation are server-specific; imported here rather than
        # in the shared nixosModules so they don't affect other hosts.
        inputs.disko.nixosModules.disko
        inputs.preservation.nixosModules.default

        ./_configuration.nix
        ./_hardware-configuration.nix
        ./_disko.nix
        ./_preservation.nix
      ]
      ++ (builtins.attrValues self.nixosModules);
  };
}
