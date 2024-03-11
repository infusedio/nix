input@{ lib, pkgs, dev, machine, ... }:

let
  config = input.config.os.hardware.network;

in
{
  options.os.hardware.network = {
    open = lib.mkOption {
      type = lib.types.bool;
      description = "Open ssh access to the host machine";
      default = false;
    };

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      description = "Ports to open on the host machine";
      default = [ ];
    };

    hosts = lib.mkOption {
      type = lib.types.str;
      description = "Hostnames to resolve";
      default = '''';
    };

    dns = lib.mkOption {
      type = lib.types.enum [
        "isp"
        "google"
        "cloudflare"
      ];
      description = "DNS service to use";
      default = "cloudflare";
    };
  };

  config = {
    networking.useDHCP = lib.mkDefault false;

    # TODO: iterate configurable, provided in options network adapters
    networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
    networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;

    users.users.${dev.name}.extraGroups = [
      "networkmanager"
    ];

    networking = {
      hostName = machine.hostname;

      networkmanager = {
        enable = true;

        insertNameservers = {
          "isp" = [ ];
          "google" = [
            "8.8.8.8"
            "8.8.4.4"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
          ];
          "cloudflare" = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
        }."${config.dns}";
      };

      firewall = {
        enable = true;
        allowPing = true;

        allowedTCPPorts = config.ports;
      };

      extraHosts = config.hosts;
    };

    services.openssh = {
      enable = config.open;
    };
  };
}
