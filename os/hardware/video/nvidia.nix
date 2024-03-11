input@{ lib, ... }:

let
  config = input.config.os.hardware.video.platform.nvidia;

in
{
  options.os.hardware.video.platform.nvidia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA support";
    };
  };

  # TODO: https://github.com/nomadics9/NixOS-Flake/blob/main/modules/nixos/nvidia.nix
  config = lib.mkIf config.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.modesetting.enable = true;
  };
}
