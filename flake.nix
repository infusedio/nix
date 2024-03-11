{
  description = "infused-nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    {
      nixosModules = {
        default = ./std;

        std = ./std;
        os = ./os;
        dev = ./dev;
      };

      devShells = {
        # default = ./env;
        # nix = ./env/nix;
        # ts = ./env/ts;
        # php = ./env/php;
      };
    };
}

