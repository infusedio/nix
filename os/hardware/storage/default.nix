input@{ lib, pkgs, ... }:

let
  config = input.config.os.hardware.storage;

in
{
  options.os.hardware.storage = { };

  config = {
    fileSystems = {
      "/" =
        {
          device = lib.mkDefault "/dev/disk/by-label/ROOT";
          fsType = "ext4";
        };

      "/boot" =
        {
          device = lib.mkDefault "/dev/disk/by-label/BOOT";
          fsType = "vfat";
        };
    };

    swapDevices = [ ];
  };
}
