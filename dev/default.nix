input@{ ... }:

let
  config = input.config.dev;

in
{
  imports = [ ];

  options.dev = { };

  config = { };
}
