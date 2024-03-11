input@{ inputs, ... }:

let
  config = input.config._dev;

in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ({ self, inputs, home-manager, dev, machine, settings, ... }: {
      nixpkgs.overlays = [ inputs.alacritty-theme.overlays.default ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit self inputs dev machine settings;
        };

        # users.${dev.name} = import ./dev;
      };
    })
    # ./dev
  ];

  options.os._dev = { };

  config = { };
}
