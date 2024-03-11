input@{ lib, pkgs, dev, ... }:

let
  config = input.config.os.hardware.kernel;

in
{
  options.os.hardware.kernel = {
    channel = lib.mkOption {
      type = lib.types.enum [
        "current"
        "latest"
      ];
      default = "current";
      description = "The kernel packages channel to use";
    };
  };

  config = {
    boot = {
      initrd = {
        availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
        kernelModules = [ ];
      };
      kernelModules = [ "kvm-amd" ];
      extraModulePackages = [ ];

      kernelPackages = lib.mkDefault
        (with pkgs; (if config.channel == "latest" then linuxPackages_latest else linuxPackages));

      kernel = {
        sysctl."fs.inotify.max_user_watches" = 524288;
      };
    };
  };
}




