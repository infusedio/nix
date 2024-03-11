input@{ lib, pkgs, ... }:

{
  config = lib.mkIf (input.config.os.hardware.video.platform == "amd") {
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
