input @ {lib, ...}: {
  # TODO: https://github.com/nomadics9/NixOS-Flake/blob/main/modules/nixos/nvidia.nix
  config = lib.mkIf (input.config.os.hardware.video.platform == "nvidia") {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = true;
    };
  };
}
