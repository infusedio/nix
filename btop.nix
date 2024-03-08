input@{ lib, config, pkgs, ... }:

let
  cfg = config.os.metrics.programs.btop;

in
{
  options.os.metrics.programs.btop = {
    enable = lib.mkEnableOption "btop";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop
    ];
  };
}
