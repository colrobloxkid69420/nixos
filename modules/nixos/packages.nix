# modules/nixos/packages.nix
{ self, inputs, ... }: {
  flake.nixosModules.packages = { lib, config, pkgs, pkgsUnstable, inputs, ... }:
  let cfg = config.myNixOS.packages; in
  {
    options.myNixOS.packages.enable = lib.mkEnableOption "system packages";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        helix
        tree
        git
        gh
        firefox-devedition
        nh
        nvd
        mpv
        pciutils
        mission-center
        lshw
        inputs.viu.packages.${pkgs.system}.default
        inputs.kwin-effects-forceblur.packages.${pkgs.system}.default
        # inputs.wivrn.packages.${pkgs.system}.default
        nodejs_24
        lexend
        multiplex
        chromium
        qbittorrent-enhanced
        libreoffice-qt-fresh
        zathura
        bisq2
        corefonts
        zed-editor
        prismlauncher
        git-lfs
        pnpm
        rustup
        direnv
        gcc
        nix-search-cli
        virtualgl
        geteduroam
        geteduroam-cli
        slack
        jdk25
        maven
        docker
        protontricks
        pandoc
        pkgsUnstable.zoom-us
        alvr
        easyeffects
        element-desktop
        zsh
        mpich
        fzf
        ncdu
        claude-code
        cmake
        ags_1
        stremio-linux-shell
        eza
        zoxide
        via
        unixtools.ifconfig
        selectdefaultapplication
        gnome-calendar
        gnome-control-center
        gnumake
        hyprpicker
        pinta
        networkmanager
        kitty
        python310
        prover9
        cudaPackages.cuda_nvcc
        kdePackages.kservice
        haskell.compiler.native-bignum.ghcHEAD
        inputs.nix-index-database.packages.${pkgs.system}.default
      ];
    };
  };
}
