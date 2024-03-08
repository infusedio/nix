input@{ lib, config, pkgs, ... }:

let
  cfg = config.os.metrics.programs.bottom;

in
{
  options.os.metrics.programs.bottom = {
    enable = lib.mkEnableOption "bottom";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bottom
    ];
  };
}
