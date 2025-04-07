{
  # required by impermanence
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "mode=755" ];
    };

    disk.main = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            label = "ESP";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            size = "100%";
            type = "8304";
            label = "ROOT";
            content = {
              type = "luks";
              name = "nixos";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L NixOS"
                ];
                subvolumes = {
                  # mount the top-level subvolume at /btr_pool
                  # it will be used by btrbk to create snapshots
                  "/" = {
                    mountpoint = "/btr_pool";
                    # btrfs's top-level subvolume, internally has an id 5
                    # we can access all other subvolumes from this subvolume.
                    mountOptions = ["subvolid=5"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = ["compress-force=zstd:1" "noatime"];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16384M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
