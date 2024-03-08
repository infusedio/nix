input@{ lib, config, ... }:

let
  cfg = config.os.metrics;

in
{
  imports = [
    ./bottom.nix
    ./btop.nix
  ];

  options.os.metrics = {
    enable = lib.mkEnableOption "metrics";

    monitor = lib.mkOption {
      type = lib.types.enum [
        "bottom"
        "btop"
      ];
      example = "btop";
      description = "The monitoring tool to use";
    };
  };

  config = lib.mkIf cfg.enable
    {
      os.metrics.programs.bottom.enable = cfg.monitor == "bottom";
      os.metrics.programs.btop.enable = cfg.monitor == "btop";
    };
}

