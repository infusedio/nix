{ config, inputs, lib, pkgs, dev, machine, settings, ... }:

let
  paths = {
    home = config.home.homeDirectory;
  };

  import-assets = inputs.nix-filter.lib;

  ui = with pkgs; {
    assets = import-assets {
      root = ./config/assets;
    };

    terminal = {
      name = "alacritty";

      font = {
        package = (nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
        name = "JetBrainsMono Nerd Font";
        size = dev.ui.font.size or 10;
      };

      theme = {
        package = alacritty-theme.tokyo-night;
      };
    };

    gtk = {
      theme = {
        package = tokyo-night-gtk; # TODO: change to `tokyo-night-gtk-theme` when this is merged to unstable: https://github.com/NixOS/nixpkgs/pull/284621
        name = "Tokyonight-Dark-BL"; # NOTE: https://www.pling.com/p/1681315
      };

      font = {
        package = roboto;
        name = "Roboto";
        size = dev.ui.font.size or 10;
      };

      cursor = {
        package = bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 36;
      };

      icon = {
        package = gnome.adwaita-icon-theme;
        name = "Adwaita";
      };
    };
  };

in
{
  nix = {
    settings = {
      extra-substituters = [
        "https://attic.alexghr.me/public" # inputs.alacritty-theme
      ];

      extra-trusted-public-keys = [
        "public:5MqPjBBGMCWbo8L8voeQl7HXc5oX+MXZ6BSURfMosIo=" # inputs.alacritty-theme
      ];
    };
  };

  home = {
    stateVersion = settings.state;

    username = dev.name;
    homeDirectory = "/home/${dev.name}";

    packages = with pkgs; [
      ntfs3g

      wget
      zip
      unzip
      lsof
      fd
      grc
      tree-sitter

      tldr
      tree
      httpie
      glow
      neofetch
      nix-output-monitor

      cloudflared
      speedtest-cli

      wev
      wl-clipboard
      grimblast
      playerctl
      pavucontrol

      google-chrome
      spotify
      vlc
      slack
      discord
      webcord

      mysql
      dbeaver
      qbittorrent
      calibre

      ui.terminal.font.package
      ui.gtk.font.package

      hyprpaper # TODO: move to hyprland

      # TODO: define in project flakes:
      # these are to enable relevant lsps in neovim
      nodejs
      cargo
      eslint_d
    ];

    pointerCursor = with ui.gtk.cursor; {
      inherit package name size;

      gtk = {
        enable = true;
      };
    };

    sessionVariables.GTK_THEME = ui.gtk.theme.name;

    # TODO: ingest all as a nix fileset and iterate into the "preload" hyprpaper command
    # TODO: the entire file handling situation here is not good, it should all be references to nix ingested files
    file.".config/hypr/hyprpaper.conf" =
      let
        # NOTE: customize by just passing a path to an ingested asset
        wallpaper = "${ui.assets}/wallpapers/wallhaven-y8er97.png";
      in
      {
        text = ''
          splash = false

          preload = ${wallpaper}
          wallpaper = ${(lib.head machine.devices.displays).output},${wallpaper}
        '';
      };
  };

  services = {
    gpg-agent = {
      enable = true;

      pinentryPackage = pkgs.pinentry-curses;

      defaultCacheTtl = 86400; # 1 day
      maxCacheTtl = 604800; # 1 week

      enableZshIntegration = true;

      # TODO:
      # enableSshSupport = true;
      # defaltCacheTtlSsh = 86400; # 1 day
      # maxCacheTtlSsh = 604800; # 1 week
      # sshKeys = [ ];
    };

    swayosd = {
      enable = true;
    };

    playerctld = {
      enable = true;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    zsh = {
      enable = true;

      autosuggestion = {
        enable = true;
      };

      syntaxHighlighting = {
        enable = true;

        # TODO: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
        styles = { };
      };

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      # NOTE: customize
      shellAliases =
        let
          paths = {
            flake = "$HOME/dev/${dev.handle}-nix";
          };

          commands = {
            input = {
              update = (input: flake_path: "nix flake lock --update-input ${input} ${flake_path}");
            };
            flake = {
              build = (flake_path: "sudo nixos-rebuild build --flake ${flake_path} --show-trace");
              switch = (flake_path: "sudo nixos-rebuild switch --flake ${flake_path} --show-trace");
            };
          };
        in
        {
          # nix
          switch = "${commands.input.update "infused-nix" paths.flake} && ${commands.flake.switch paths.flake}";

          # zoxide
          cd = "z";

          # bun
          b = "bun";
          bx = "bunx";
          bi = "bun install";
          bid = "bun install -D";

          # nx
          n = "bunx nx";

          # docker
          d = "docker";

          # containers
          dgc = "docker ps";
          dgca = "docker ps -a";

          # kubernetes
          k = "kubectl";

          # all
          kga = "kubectl get all";
          kgaa = "kubectl get all --all-namespaces";

          # node
          kgn = "kubectl get nodes";

          # pod
          kgp = "kubectl get pods";
          kgpa = "kubectl get pods --all-namespaces";
          kdp = "kubectl describe pod";
          kdpa = "kubectl describe pod --all-namespaces";

          # deployment
          kgd = "kubectl get deployments";
          kgda = "kubectl get deployments --all-namespaces";
          kdd = "kubectl describe deployment";
          kdda = "kubectl describe deployment --all-namespaces";

          # service
          kgs = "kubectl get services";
          kgsa = "kubectl get services --all-namespaces";
          kds = "kubectl describe service";
          kdsa = "kubectl describe service --all-namespaces";
        };
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;

        character =
          let
            modes = rec {
              normal = {
                symbol = "󰁔";
                color = "#c3e88d";
              };

              insert = {
                symbol = normal.symbol;
                color = "#ff757f";
              };

              replace = {
                symbol = insert.symbol;
                color = "#c53b53";
              };

              visual = {
                symbol = insert.symbol;
                color = "#3d59a1";
              };
            };
          in
          {
            vimcmd_symbol = with modes.normal; "[${symbol}](bold ${color})";
            error_symbol = "[](bold #ffc777)";
            success_symbol = with modes.insert; "[${symbol}](bold ${color})";

            # BUG: these do not have any effect, potentially due to zsh-vi-mode plugin treating these modes differently?
            vimcmd_replace_one_symbol = with modes.replace; "[${symbol}](bold ${color})";
            vimcmd_replace_symbol = with modes.replace; "[${symbol}](bold ${color})";
            vimcmd_visual_symbol = with modes.visual; "[${symbol}](bold ${color})";
          };

        nix_shell = {
          format = "via [$symbol]($style)";
          symbol = "󱄅 ";
        };
      };
    };

    zoxide = {
      enable = true;

      enableZshIntegration = true;

      # https://github.com/ajeetdsouza/zoxide?tab=readme-ov-file#configuration
      options = [ ];
    };

    ripgrep = {
      enable = true;

      # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-filefor
      arguments = [ ];
    };

    fzf = {
      enable = true;

      enableZshIntegration = true;
      tmux = {
        enableShellIntegration = true;

        # fzf-tmux --help for available options
        shellIntegrationOptions = [ ];
      };
    };

    jq = {
      enable = true;
    };

    # TODO: after nix-sops
    # atuin = {
    #  enable = true;
    #
    #  enableZshIntegration = true;
    # };

    bat = {
      enable = true;
    };

    htop = {
      enable = true;
    };

    btop = {
      enable = true;
    };

    alacritty = with ui.terminal; {
      enable = true;

      settings = {
        import = [
          ui.terminal.theme.package
        ];

        # TODO: iterate map { normal = "Regular", ... }
        font = with font; {
          inherit size;

          normal = {
            family = name;
            style = "Regular";
          };

          bold = {
            family = name;
            style = "Bold";
          };

          italic = {
            family = name;
            style = "Italic";
          };

          bold_italic = {
            family = name;
            style = "Bold Italic";
          };
        };
      };
    };

    direnv = {
      enable = true;

      enableZshIntegration = true;

      nix-direnv = {
        enable = true;
      };
    };

    ssh = {
      enable = true;

      serverAliveInterval = 240;
      serverAliveCountMax = 2;

      matchBlocks =
        let
          github = "github.com";
        in
        {
          ${github} = {
            hostname = github;
            user = dev.name;
            identityFile = "~/.ssh/${dev.name}.pem";
          };
        };
    };

    gpg = {
      enable = true;

      homedir = "${paths.home}/.gpg";

      # NOTE: make immutable when age or sops is introduced
      mutableKeys = true;
      mutableTrust = true;
    };

    git = {
      enable = true;

      userName = dev.name;
      userEmail = dev.email;

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    tmux = {
      enable = true;

      terminal = "tmux-256color";
      prefix = "F12";
      baseIndex = 1;
      historyLimit = 100000;
      escapeTime = 0;

      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = "set -g @resurrect-strategy-nvim 'session'";
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '0' # disable
          '';
        }
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour "macchiato"

            set -g @catppuccin_pill_theme_enabled "off"
            set -g @catppuccin_no_patched_fonts_theme_enabled "off"

            set -g @catppuccin_window_tabs_enabled "on"
            set -g @catppuccin_user "off"
            set -g @catppuccin_host "off"

            set -g @catppuccin_left_separator "█"
            set -g @catppuccin_right_separator "█"
          '';
        }
        {
          plugin = tmux-fzf;
        }
        {
          plugin = yank;
        }
      ];

      extraConfig = ''
        # truecolor
        set-option -sa terminal-features ',${ui.terminal.name}:RGB'

        # https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#fix-undercurls-in-tmux
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

        # mouse
        set -g mouse on

        # status
        set-option -g allow-rename "off"
        set-option -g automatic-rename "off"
        set-option -g display-time 1000
        set-option -g status-interval 1

        # sessions
        unbind s
        bind-key F12 choose-tree -Zs

        # windows
        set-option -g renumber-windows "on"

        # NOTE: navigate between tmux windows with ctrl+alt+arrow, needs to be backed by alacritty keys defined in: github:medv-vault/.medv
        # set -s user-keys[0] "\e[1;6D" # Ctrl+Alt+Left (defined in alacritty.yml)
        # set -s user-keys[1] "\e[1;6C" # Ctrl+Alt+Right (defined in alacritty.yml)
        bind-key -n User0 previous-window
        bind-key -n User1 next-window

        # tmux.nvim
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'M-Up' if-shell "$is_vim" 'send-keys M-Up' { if -F '#{pane_at_top}' \'\' 'select-pane -U' }
        bind-key -n 'M-Right' if-shell "$is_vim" 'send-keys M-Right' { if -F '#{pane_at_right}' \'\' 'select-pane -R' }
        bind-key -n 'M-Down' if-shell "$is_vim" 'send-keys M-Down' { if -F '#{pane_at_bottom}' \'\' 'select-pane -D' }
        bind-key -n 'M-Left' if-shell "$is_vim" 'send-keys M-Left' { if -F '#{pane_at_left}' \'\' 'select-pane -L' }
        bind-key -T copy-mode-vi 'M-Up' if -F '#{pane_at_top}' \'\' 'select-pane -U'
        bind-key -T copy-mode-vi 'M-Right' if -F '#{pane_at_right}' \'\' 'select-pane -R'
        bind-key -T copy-mode-vi 'M-Down' if -F '#{pane_at_bottom}' \'\' 'select-pane -D'
        bind-key -T copy-mode-vi 'M-Left' if -F '#{pane_at_left}' \'\' 'select-pane -L'

        # disable selecting last layout through <Prefix>Space
        unbind -n M-Space
        unbind-key -T prefix Space

        # normal mode
        setw -g mode-keys vi
        bind-key v copy-mode
        unbind-key [
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi Escape if-shell -F "#{?selection_present,1,0}" "send-keys -X clear-selection" "send-keys -X cancel"
        # bind-key -T copy-mode-vi Escape send-keys -X cancel
        bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
      '';
    };

    neovim = {
      enable = true;

      defaultEditor = true;
    };

    lazygit = {
      enable = true;

      settings = {
        disableStartupPopups = true;
        confirmOnQuit = true;
        promptToReturnFromSubprocess = false;

        git = {
          overrideGpg = true;
        };

        gui = {
          showPanelJump = false;
          showBottomLine = false;
          showRandomTip = false;
          nerdFontsVersion = "3";

          skipStashWarning = true;
          skipDiscardChangeWarning = true;
          skipRewordInEditorWarning = true;
        };

        refresher = {
          refreshInterval = 1;
        };

        keybinding = {
          universal = {
            quit = "q";
            quit-alt1 = "";
            quitWithoutChangingDirectory = "";
            undo = "u";
            redo = "U";
          };
        };
      };
    };

    k9s = {
      enable = true;

      settings = {
        refreshRate = 1;
        maxConnRetry = 100;
        enableMouse = true;
        headless = false;
        crumbsless = false;
        readOnly = false;
        noExitOnCtrlC = false;
        noIcons = false;
        skipLatestRevCheck = false;
        logger = {
          tail = 1000;
          buffer = 1000;
          sinceSeconds = -1;
          fullScreenLogs = true;
          textWrap = false;
          showTime = false;
        };
      };

      # TODO: https://mynixos.com/home-manager/option/programs.k9s.skin
      # https://github.com/axkirillov/k9s-tokyonight/blob/main/skin.yml
      # skin = {};
    };
  };

  gtk = with ui.gtk; {
    enable = true;

    theme = with theme; {
      inherit package name;
    };

    iconTheme = with icon; {
      inherit package name;
    };

    font = with font; {
      inherit package name;
    };
  };

  fonts.fontconfig.enable = true;

  wayland.windowManager.hyprland =
    let
      keymap = {
        prefix = "SUPER";
        nav = "${keymap.prefix}";
        move = "SHIFT_${keymap.prefix}";
        resize = "CTRL_SHIFT_${keymap.prefix}";
        slide = "ALT_${keymap.prefix}";
        teleport = "SHIFT_ALT_${keymap.prefix}";
      };

    in
    {
      enable = true;

      settings = with pkgs; {
        "exec-once" = [
          "${alacritty}/bin/alacritty --title \"PERSISTENT_WORKSPACE_1\" &"
          "${alacritty}/bin/alacritty --title \"PERSISTENT_WORKSPACE_2\" &"
          "${alacritty}/bin/alacritty --title \"PERSISTENT_WORKSPACE_3\" &"

          "${hyprpaper}/bin/hyprpaper &"

          "${alacritty}/bin/alacritty --title \"P_TERMINAL_1\" --option \"window.padding={x=20,y=20}\" &"
          "${alacritty}/bin/alacritty --title \"P_TERMINAL_2\" --option \"window.padding={x=20,y=20}\" &"

          "${alacritty}/bin/alacritty --title \"MAIN_TERMINAL_1\" --command tmux attach &"

          "${webcord}/bin/webcord &"
          "${slack}/bin/slack &"
          "${spotify}/bin/spotify &"

          "${swayosd}/bin/swayosd-server &"
        ];

        monitor = with lib.head machine.devices.displays;
          "${output},${toString resolution.width}x${toString resolution.height}@${toString resolution.at},0x0,1";

        general = {
          layout = "master";

          border_size = 0;
          # TODO: should come from theme palette
          "col.inactive_border" = "0xff3d59a1 0xff394b70 45deg";
          "col.active_border" = "0xffbb9af7 0xff9d7cd8 45deg";

          # NOTE: customizable
          gaps_in = 5;
          gaps_out = 5;
          gaps_workspaces = 5;

          no_cursor_warps = true;
          resize_on_border = true;
          no_focus_fallback = true;
        };

        dwindle = {
          force_split = 2;
          smart_resizing = false;
        };

        master = {
          orientation = "center";
          always_center_master = true;
          new_is_master = false;
          new_on_top = false;
        };

        input = {
          repeat_delay = "200";
          repeat_rate = "65";

          follow_mouse = 2;
          mouse_refocus = false;
        };

        workspace = [
          "special:p,persistent:true,bordersize:2,gapsin:40,gapsout:40"

          "1,persistent:true"
          "2,persistent:true,default:true"
          "3,persistent:true"
        ];

        windowrulev2 = [
          "float,title:^PERSISTENT_WORKSPACE.*$"
          "nofocus,title:^PERSISTENT_WORKSPACE.*$"
          "noblur,title:^PERSISTENT_WORKSPACE.*$"
          "size 0 0,title:^PERSISTENT_WORKSPACE.*$"
          "move 0 0,title:^PERSISTENT_WORKSPACE.*$"
          "opacity 0,title:^PERSISTENT_WORKSPACE.*$"
          "workspace 1 silent,title:^(PERSISTENT_WORKSPACE_1)$"
          "workspace 2 silent,title:^(PERSISTENT_WORKSPACE_2)$"
          "workspace 3 silent,title:^(PERSISTENT_WORKSPACE_3)$"

          "workspace 2,title:^(MAIN_TERMINAL_1)$"

          "workspace 3 silent,class:^(WebCord)$"
          "workspace 3 silent,class:^(Slack)$"

          "workspace special:p silent,title:^(P_TERMINAL_1)$"
          "workspace special:p silent,title:^(P_TERMINAL_2)$"
          "workspace special:p silent,title:^(Spotify)"

          "float,title:^Bitwarden$"
          "float,class:^(pavucontrol)$"
        ];

        bind =
          with keymap; [
            "${prefix},q,killactive"

            "${prefix},return,exec,${alacritty}/bin/alacritty"

            "${prefix},d,exec,${webcord}/bin/webcord --disable-features=WaylandFractionalScaleV1"
            "${prefix},m,exec,${spotify}/bin/spotify --disable-features=WaylandFractionalScaleV1"
            "${prefix},w,exec,${google-chrome}/bin/google-chrome-stable --restore-last-session --hide-crash-restore-bubble --disable-features=WaylandFractionalScaleV1"
            "${prefix},s,exec,${grimblast}/bin/grimblast copy area"
            "ALT_${prefix},s,exec,${grimblast}/bin/grimblast copy screen"

            "${nav},up,movefocus,u"
            "${nav},right,movefocus,r"
            "${nav},down,movefocus,d"
            "${nav},left,movefocus,l"

            "${move},up,movewindow,u"
            "${move},right,movewindow,r"
            "${move},down,movewindow,d"
            "${move},left,movewindow,l"

            "${resize},f,fullscreen,0"
            "${resize},g,fakefullscreen"

            "${prefix},f,togglefloating"
            "${prefix},t,pin"
            "${prefix},c,centerwindow"

            "${slide},right,workspace,e+1"
            "${slide},left,workspace,e-1"
            "${slide},mouse_up,workspace,e+1"
            "${slide},mouse_down,workspace,e-1"
            "${prefix},p,togglespecialworkspace,p"

            "${teleport},right,movetoworkspacesilent,e+1"
            "${teleport},left,movetoworkspacesilent,e-1"
            "${teleport},p,movetoworkspacesilent,special:p"

            "ALT_${prefix},XF86AudioPlay,exec,${playerctl}/bin/playerctl play-pause --all-players"
            "${prefix},XF86AudioPlay,exec,${playerctl}/bin/playerctl play-pause --player chromium"
            ",XF86AudioPlay,exec,${playerctl}/bin/playerctl play-pause --player spotify"

            ",XF86AudioNext,exec,${playerctl}/bin/playerctl next --player spotify"
            ",XF86AudioPrev,exec,${playerctl}/bin/playerctl previous --player spotify"
          ];

        # TODO: remove shift modifier when corne keymap has been updated to fix the media layer
        binde = with keymap; [
          "${resize},up,resizeactive,0 -20"
          "${resize},right,resizeactive,20 0"
          "${resize},down,resizeactive,0 20"
          "${resize},left,resizeactive,-20 0"

          "SHIFT,XF86AudioRaiseVolume,exec,${swayosd}/bin/swayosd-client --output-volume=\"+1\""
          "SHIFT,XF86AudioLowerVolume,exec,${swayosd}/bin/swayosd-client --output-volume=\"-1\""
        ];

        bindm = with keymap; [
          "${move},mouse:272,movewindow"
          "${resize},mouse:272,resizewindow"
        ];

        decoration = {
          rounding = 7;

          active_opacity = 1.00;
          inactive_opacity = 0.95;
          fullscreen_opacity = 1.00;
          dim_special = 0.75;
          blur = {
            popups = true;
          };
        };

        bezier = [
          "easeOutQuint,0.22,1,0.36,1"
          "easeInOutQuint,0.83,0,0.17,1"
        ];

        animation = [
          "workspaces,1,2,easeInOutQuint,slide"
          "specialWorkspace,1,3,easeOutQuint,fade"
          "windows,1,2,easeOutQuint,popin"
        ];

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;

          vrr = 1;
        };
      };
    };
}


