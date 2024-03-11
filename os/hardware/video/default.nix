input@{ lib, ... }:

let
  config = config.os.hardware.video;

in
{
  imports = [
    ./vendor/amd.nix
    ./vendor/nvidia.nix
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

  config = lib.mkMerge [
    {
      hardware.opengl.enable = true;

      environment = {
        sessionVariables = {
          NIXOS_OZONE_WL = "1";
          WLR_NO_HARDWARE_CURSORS = "1";
        };
      };
    }
  ];
}

