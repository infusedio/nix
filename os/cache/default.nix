input@{ lib, pkgs, dev, ... }:

let
  config = input.config.os.cache;

in
{
  options.os.cache = { };

  config = {
    nix = {
      settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };
}

