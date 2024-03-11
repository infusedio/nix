input@{ lib, pkgs, dev, ... }:

let
  config = input.config.os.cache;

in
{
  options.os.cache = { };

  config = {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];

        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };
  };
}

