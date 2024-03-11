input@{ lib, dev, ... }:

let
  config = input.config.os.hardware.audio;

in
{
  options.os.hardware.audio = { };

  config = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      pulse = {
        enable = true;
      };
    };
  };
}
