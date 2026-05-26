# modules/hosts/server/_configuration.nix

{ config, pkgs, inputs, ... }:
{
  networking.hostName = "server";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

  nixpkgs.config.allowUnfree = true;

  # ── Shared feature enables ───────────────────────────────────────────────────
  # Only pull in modules that make sense on a headless server.
  myNixOS = {
    boot.enable    = true;
    locale.enable  = true;
    zsh.enable     = true;
    nix.enable     = true;
    # Disabled on server:
    #   nvidia, power, desktop, hyprland, audio, bluetooth,
    #   gaming, docker, fonts, packages, equibop, noctalia,
    #   hardware.gigabyteLaptop, services (open-webui / timekpr),
    #   users (defined below — server has different accounts)
  };

  # ── Boot (btrfs + systemd-in-initrd, on top of myNixOS.boot) ────────────────
  boot.initrd.systemd.enable       = true;
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.supportedFilesystems        = [ "btrfs" ];

  # ── Users ────────────────────────────────────────────────────────────────────
  users.users.crazykazoo = {
    isNormalUser = true;
    description  = "Yoav Cohen";
    extraGroups  = [ "wheel" "networkmanager" ];
    # hashedPasswordFile = "/persist/etc/nixos/secrets/crazykazoo-password";
    initialPassword = "changeme";
    shell = pkgs.zsh;
    packages = [];
  };

  users.users.kattenelvis = {
    isNormalUser = true;
    description  = "CENSORED";
    extraGroups  = [ "wheel" "networkmanager" ];
    # hashedPasswordFile = "/persist/etc/nixos/secrets/kattenelvis-password";
    initialPassword = "changeme";
    packages = [];
  };

  # ── Packages ──────────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    eza
    zoxide
    fzf
    git
    vim
    curl
    wget
    htop
    helix
    zellij
    fastfetch
  ];

  # ── Services ──────────────────────────────────────────────────────────────────
  services.envfs.enable = true;

  services.openssh = {
    enable                         = true;
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin        = "no";
  };

  programs.nh = {
    enable            = true;
    clean.enable      = true;
    clean.extraArgs   = "--keep-since 4d --keep 3";
  };

  # ── Commented-out services (ready to enable) ─────────────────────────────────
  # Cloudflare dynamic DNS:
  # age.secrets.cloudflare-token.file = ./secrets/cloudflare-token.age;
  # services.cloudflare-dyndns = {
  #   enable       = true;
  #   apiTokenFile = config.age.secrets.cloudflare-token.path;
  #   domains      = [ "yoavco.com" ];
  #   proxied      = true;
  # };

  # SearXNG:
  # services.searx = {
  #   enable               = true;
  #   redisCreateLocally   = true;
  #   settings.server = {
  #     bind_address    = "0.0.0.0";
  #     port            = 8888;
  #     environmentFile = "/etc/nixos/secrets/.searxng.env";
  #   };
  # };

  system.stateVersion = "25.11";
}
