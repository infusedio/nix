input @ {
  lib,
  pkgs,
  dev,
  ...
}: let
  config = input.config.os.hardware.bluetooth;
in {
  options.os.hardware.bluetooth = {};

  config = {
    hardware.bluetooth = {
      enable = true;
    };

    services.blueman = {
      enable = true;
    };

    # TODO:
    # iterate dev.devices.headphones
    # iterate dev.devices.speakers
    # get list of devices that are marked as "autoconnect": true
    # iterate that list:
    systemd.services.bluetooth-autoconnect = with (lib.head dev.devices.headphones).bluetooth; {
      description = "Autoconnect to ${address} headphones";
      after = ["blutooth.service"];
      wantedBy = ["multi-user.target"];
      script = ''
        while ! ${pkgs.bluez}/bin/bluetoothctl connect ${address}; do
          sleep 3
        done
      '';
    };
  };
}
