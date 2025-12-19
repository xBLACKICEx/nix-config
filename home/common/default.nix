{ inputs, pkgs,... }:
{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          eame = "xblackicex";
          email = "xblackicex@outlook.com";
        };
      };
    };

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        kb = "kubectl";
        ls = "lsd";
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      };
    };

    nushell.enable = true;
    nushell.package = pkgs.nushell.override {
      additionalFeatures = p: p ++ [ "mcp" ];
    };
    nushell.extraConfig = ''
      $env.config.keybindings = [
        {
          name: fuzzy_filefind
          modifier: control
          keycode: char_t
          mode: [emacs vi_normal vi_insert]
          event: [
            {
              send: ExecuteHostCommand
              cmd: "
                              if ((commandline | str trim | str length) == 0) {

                              # if empty, search and use result
                              (fzf --preview 'bat -n --color=always {}' --layout=reverse | decode utf-8 | str trim)

                              } else if (commandline | str ends-with ' ') {

                              # if trailing space, search and append result
                              [
                                  (commandline)
                                  (fzf --preview 'bat -n --color=always {}' --layout=reverse | decode utf-8 | str trim)
                              ] | str join

                              } else {
                              # otherwise search for last token

                              [
                                  (commandline | split words | reverse | skip 1 | reverse | str join ' ')
                                  (fzf
                                      --layout=reverse
                                      --preview 'bat -n --color=always {}'
                                      -q (commandline | split words | last)
                                  | decode utf-8 | str trim)
                              ] | str join ' '

                              }
                          "
            }
          ]
        }
        {
          name: change_dir_with_fzf
          modifier: control
          keycode: char_y
          mode: [emacs vi_normal vi_insert]
          event: {
            send: ExecuteHostCommand
            cmd: "zi"
          }
        }
      ]
    '';

    atuin = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile "${inputs.dotfiles}/general/atuin/config.toml");
      enableNushellIntegration = true;
      enableBashIntegration = true;
    };

    carapace = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
  };

    starship = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      settings = builtins.fromTOML (builtins.readFile "${inputs.dotfiles}/general/starship.toml");
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      changeDirWidgetCommand = "fd --type d";
    };

    yazi = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
    };
  };

  services = {
    pueue = {
      enable = true;
      settings = {
        client = {
          restart_in_place = false;
          read_local_logs = true;
          show_confirmation_questions = false;
          show_expanded_aliases = false;
          dark_mode = false;
          max_status_lines = null;
          status_time_format = "%H:%M:%S";
          status_datetime_format = "%Y-%m-%d\n%H:%M:%S";
        };
        daemon = {
          pause_group_on_failure = false;
          pause_all_on_failure = false;
          callback = null;
          env_vars = { };
          callback_log_lines = 10;
          shell_command = null;
        };
        shared = {
          pueue_directory = null;
          runtime_directory = null;
          alias_file = null;
          use_unix_socket = true;
          unix_socket_path = null;
          host = "127.0.0.1";
          port = "6924";
          pid_path = null;
          daemon_cert = null;
          daemon_key = null;
          shared_secret_path = null;
        };
        profiles = { };
      };
    };
  };

}
