{
  description = "infusedpkgs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    {
      nixosModules.default = ./default.nix;
    };
}

