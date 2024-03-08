input@{ lib, ... }:

let
  config = input.config.os;

in
{
  imports = [
    # ./cache
    ./environment
    # ./hardware
    # ./interface
  ];

  # options.os = {
  # monitor = lib.mkOption {
  #   type = lib.types.enum [
  #     "bottom"
  #     "btop"
  #   ];
  #   example = "btop";
  #   description = "The monitoring tool to use";
  # };
  # };

  # config = lib.mkIf cfg.enable
  #   {
  #
  #     os.metrics.programs.bottom.enable = cfg.monitor == "bottom";
  #     os.metrics.programs.btop.enable = cfg.monitor == "btop";
  #   };
}

