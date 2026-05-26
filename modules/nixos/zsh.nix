# modules/nixos/zsh.nix
{ self, inputs, ... }: {
  flake.nixosModules.zsh = { lib, config, pkgs, ... }:
  let cfg = config.myNixOS.zsh; in
  {
    options.myNixOS.zsh.enable = lib.mkEnableOption "zsh with oh-my-zsh";

    config = lib.mkIf cfg.enable {
      programs.zsh = {
        enable                = true;
        enableBashCompletion  = true;
        autosuggestions.enable       = true;
        syntaxHighlighting.enable    = true;

        ohMyZsh = {
          enable  = true;
          plugins = [
            "git"
            "aliases"
            "alias-finder"
            "common-aliases"
            "eza"
            "fzf"
            "rust"
            "zoxide"
          ];
          custom = "$HOME/.oh-my-zsh/custom/";
          theme  = "powerlevel10k/powerlevel10k";
        };
      };
    };
  };
}
