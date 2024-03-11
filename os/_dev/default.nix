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

        users.${dev.name} = import ./dev.nix;
      };
    })
  ];

  # TODO: options are not set properly, we are using `dev` global set directly, this is not type safe
  # parametarize everything properly while refactoring #os._dev to its own output
  options.os._dev = { };

  config = { };
}
