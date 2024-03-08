input@{ lib, pkgs, ... }:

let
  config = input.config.os.hardware;

in
{
  options.os.hardware = { };

  config = { };
}


