input@{ lib, settings, ... }:

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
        enable = config.enable;
      };
    };

    # add user to docker group
    users.users.${settings.dev.user.name} = {
      extraGroups = [ "docker" ];
    };
  };
}


