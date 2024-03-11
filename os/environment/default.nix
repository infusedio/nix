input@{ lib, pkgs, dev, ... }:

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
        default = "en_NZ.UTF-8";
      };
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "List of packages to be installed on the system level";
      default = [ ];
    };

    libraries = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of libraries to be dynamically linked through `nix-ld`";
    };

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = dev.name;
      };
      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };

    shell = {
      variables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };
  };

  config = {
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        extra-trusted-users = [
          config.user.name or dev.name
        ];
      };
    };

    time = {
      timeZone = config.i18n.timezone;
    };

    i18n = with config.i18n; {
      defaultLocale = locale;
      extraLocaleSettings = {
        LC_ADDRESS = locale;
        LC_IDENTIFICATION = locale;
        LC_MEASUREMENT = locale;
        LC_MONETARY = locale;
        LC_NAME = locale;
        LC_NUMERIC = locale;
        LC_PAPER = locale;
        LC_TELEPHONE = locale;
        LC_TIME = locale;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        git
        curl
        wget
        neovim
      ] ++ config.packages;

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      } // config.shell.variables;
    };

    programs.nix-ld = {
      enable = true;

      libraries = with pkgs; [ ] ++ config.libraries;
    };

    programs = {
      zsh = {
        enable = true;
      };

      dconf = {
        enable = true;
      };
    };

    users = {
      defaultUserShell = pkgs.zsh;

      users.${config.user.name} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ] ++ config.user.groups;
      };
    };
  };
}

