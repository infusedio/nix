input@{ lib, settings, ... }:

let
  config = input.config.os;

in
{
  imports = [
    ./_dev
    ./cache
    ./environment
    ./hardware
    ./interface
  ];

  options.os = { };

  config = {
    system.stateVersion = settings.state;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    nixpkgs = {
      config = {
        allowUnfree = lib.mkDefault true;
        cudaSupport = lib.mkDefault true; # this will break amd platforms, just hotwiring it to test vllm, we can read video platform config ("amd" | "nvidia")
      };
    };
  };
}
