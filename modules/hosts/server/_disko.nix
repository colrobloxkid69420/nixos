{
  fileSystems."/nix".neededForBoot = true;

  disko.devices.nodev = {
    "/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };
  };

  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";

    content.type = "gpt";

    # BIOS compatibility boot partition (1 MiB, keep even on UEFI systems)
    content.partitions.boot = {
      name = "boot";
      size = "1M";
      type = "EF02";
    };

    # EFI System Partition
    content.partitions.esp = {
      name = "ESP";
      size = "1G";
      type = "EF00";

      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };

    # Swap partition (adjust size to ~= your RAM for hibernation support)
    content.partitions.swap = {
      size = "16G";

      content = {
        type = "swap";
        resumeDevice = true; # enables hibernate/resume from swap
      };
    };

    # Root partition — entire remaining space, formatted as btrfs
    content.partitions.root = {
      name = "root";
      size = "100%";

      content = {
        type = "btrfs";
        extraArgs = ["-f"]; # force overwrite if partition already exists

        subvolumes = {
          # Persistent state that survives reboots
          "/persistent" = {
            mountOptions = ["subvol=persistent" "noatime" "compress=zstd"];
            mountpoint = "/persistent";
          };

          # Nix store — large, read-heavy, benefits from noatime
          "/nix" = {
            mountOptions = ["subvol=nix" "noatime" "compress=zstd"];
            mountpoint = "/nix";
          };
          
          # Home
          "/home" = {
            mountOptions = ["subvol=home" "noatime" "compress=zstd"];
            mountpoint = "/home";
          };
        };
      };
    };
  };
}

