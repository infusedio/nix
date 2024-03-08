input@{ lib, pkgs, ... }:

let
  config = input.config.os.hardware;

in
{
  imports = [
    ./virtual
  ];

  options.os.hardware = { };

  config = { };
}


