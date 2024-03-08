input@{ lib, pkgs, ... }:

let
  config = input.config.os.environment;

in
{
  options.os.environment = {
    i18n = {
      timezone = lib.mkDefault "Pacific/Auckland";
      locale = lib.mkDefault "en_NZ.UTF-8";
    };

    packages = lib.mkDefault [ ];

    shell = {
      variables = lib.mkDefault { };
    };
  };

  config = lib.mkIf config.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };

    # time.timeZone = nyx.i18n.timezone;
    # i18n = with nyx.i18n; {
    #   defaultLocale = locale;
    #   extraLocaleSettings = {
    #     LC_ADDRESS = locale;
    #     LC_IDENTIFICATION = locale;
    #     LC_MEASUREMENT = locale;
    #     LC_MONETARY = locale;
    #     LC_NAME = locale;
    #     LC_NUMERIC = locale;
    #     LC_PAPER = locale;
    #     LC_TELEPHONE = locale;
    #     LC_TIME = locale;
    #   };
    # };

    environment = {
      systemPackages = with pkgs; [
        bottom
      ] // config.packages;

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      } // config.shell.variables;

      zsh = {
        enable = true;
      };
    };
  };
}

