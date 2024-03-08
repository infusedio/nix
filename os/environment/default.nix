input@{ lib, pkgs, ... }:

let
  config = input.config.os.environment;

in
{
  options.os.environment = {
    i18n = {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "Pacific/Auckland";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        default = lib.mkDefault "en_NZ.UTF-8";
      };
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };

    shell = {
      variables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  config = {
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
      systemPackages = with pkgs; [ ] ++ config.packages;

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      } // config.shell.variables;
    };
  };
}

