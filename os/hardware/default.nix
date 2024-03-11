input@{ lib, pkgs, modulesPath, ... }:

let
  config = input.config.os.hardware;

in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./virtual
  ];

  options.os.hardware = {
    platform = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
    };
  };

  config = {
    nixpkgs.hostPlatform = lib.mkDefault config.platform;

    # TODO: we can split the cpu platforms into amd/intel
    # to mimic how we structure the hardware.video modules
    # for now we are on amd cpus
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  };
}


