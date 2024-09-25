input @ {
  lib,
  dev,
  pkgs-latest,
  ...
}: let
  config = input.config.os.hardware.virtual;
in {
  options.os.hardware.virtual = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virtualisation support";
    };
  };

  config = {
    users.users.${dev.name}.extraGroups = [
      "kvm"
      "libvirtd"
      "docker"
      "adbusers"
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
      };

      docker = {
        enable = lib.mkDefault config.enable;

        package = pkgs-latest.docker;
      };
    };

    programs = {
      virt-manager = {
        enable = lib.mkDefault config.enable;

        package = pkgs-latest.virt-manager;
      };
    };
  };
}
