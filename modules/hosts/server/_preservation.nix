# preservation.nix — declare what survives the tmpfs wipe on each reboot
# Docs: https://github.com/nix-community/preservation
{
  preservation = {
    enable = true;

    preserveAt."/persistent" = {

      # ── System directories ───────────────────────────────────────────────
      directories = [
        "/etc/nixos"           # your NixOS configuration
        "/var/lib/bluetooth"   # Bluetooth pairings
        "/var/log"             # system logs (optional — remove if you don't care)
        "/var/lib/systemd/coredump" # coredumps (optional)
        {
          directory = "/var/lib/nixos"; # NixOS state (UIDs/GIDs etc.)
          inInitrd = true;              # must be available before login
        }
      ];

      # ── System files ──────────────────────────────────────────────────────
      files = [
        {
          file = "/etc/machine-id"; # stable machine identity (needed by systemd/journald)
          inInitrd = true;
        }
        "/etc/adjtime" # hardware clock drift data
      ];
    };
  };
}

