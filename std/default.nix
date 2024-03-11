input@{ ... }:

let
  config = input.config.std;

in
{
  imports = [ ];

  options.std = { };

  config = { };
}
