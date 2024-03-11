input@{ lib, ... }:

let
  config = config.os.hardware.video;

in
{
  imports = [
    ./amd.nix
    ./nvidia.nix
  ];

  options.os.hardware.video = {
    platform = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "nvidia"
      ];
      description = "The GPU vendor the primary GPU is manufactured by";
    };
  };

  config = lib.mkIf config.enable
    {
      hardware.opengl.enable = true;

      os.hardware.video.platform.amd.enable = config.platform == "amd";
      os.hardware.video.platform.nvidia.enable = config.platform == "nvidia";

      environment = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          WLR_NO_HARDWARE_CURSORS = "1";
        };
      };
    };
}

