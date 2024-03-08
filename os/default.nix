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

  options.os = {
    state = "23.11";
  };

  config = {
    system.stateVersion = config.state;
  };
}

