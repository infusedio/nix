input@{ nixpkgs, lib, ... }:

let
  config = input.config.os;

in
{
  imports = [
    # ./cache
    # ./dev
    ./environment
    ./hardware
    # ./interface
  ];

  options.os = { };

  config = {
    system.stateVersion = lib.mkDefault "23.11";

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
      };
    };
  };
}
