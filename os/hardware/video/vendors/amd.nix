input@{ lib, pkgs, ... }:

let
  config = input.config.os.hardware.video.vendor.amd;

in
{
  options.os.hardware.video.vendor.amd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AMD support";
    };
  };

  config = lib.mkIf config.enable {
    hardware.opengl = {
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        amdvlk
      ];

      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };
}
