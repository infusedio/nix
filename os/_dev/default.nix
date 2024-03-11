input@{ inputs, ... }:

let
  config = input.config._dev;

in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./dev
  ];

  options.os._dev = { };

  config = { };
}
