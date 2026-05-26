# modules/services/llama-cpp.nix
{ self, inputs, ... }: {
  flake.nixosModules.llama-cpp = { lib, config, pkgs, pkgsUnstable, inputs, ... }:
  let
    cfg      = config.myNixOS.llamaCpp;
    llamaPkg = inputs.llama-cpp.packages.${pkgs.system}.cuda;
  in
  {
    # Override the stable module with the unstable one (required for modelsPreset).
    disabledModules = [ "services/misc/llama-cpp.nix" ];
    imports = [
      (inputs.nixpkgs-unstable + "/nixos/modules/services/misc/llama-cpp.nix")
    ];

    options.myNixOS.llamaCpp.enable = lib.mkEnableOption "llama.cpp inference server";

    config = lib.mkIf cfg.enable {
      services.llama-cpp = {
        enable     = true;
        host       = "0.0.0.0";
        port       = 11434;
        package    = llamaPkg;
        extraFlags = [
          "--sleep-idle-seconds"
          "60"
        ];
        modelsPreset = {
          "gemma-4-draft" = {
            hf-repo       = "unsloth/gemma-4-E4B-it-GGUF:Q4_K_M";
            hf-repo-draft = "HackAfterDark/gemma-4-e4b-it-mtp-assistant-ultralight:f16";
          };
          "gemma-4-no-draft" = {
            hf-repo = "unsloth/gemma-4-E4B-it-GGUF:Q4_K_M";
          };
        };
      };

      environment.systemPackages                  = [ llamaPkg ];
      environment.sessionVariables.LLAMA_CACHE    = "/var/cache/llama-cpp";
    };
  };
}
