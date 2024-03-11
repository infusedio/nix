input@{ lib, dev, ... }:

let
  config = input.config.os.hardware.virtual;

in
{
  options.os.hardware.virtual = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable virtualisation support";
    };
  };

  config = {
    virtualisation = {
      docker = {
        enable = lib.mkDefault config.enable;
      };
    };

    users.users.${dev.name} = {
      extraGroups = [ "docker" ];
    };
  };
}


