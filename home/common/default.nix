{
  programs = {
    git = {
      enable = true;
      userName = "xblackicex";
      userEmail = "xblackicex@outlook.com";
    };

    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        kb = "kubectl";
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      };
    };

    nushell.enable = true;

    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
    };

    direnv.enable = true;
    direnv.enableBashIntegration = true;
    direnv.nix-direnv.enable = true;

    starship = {
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
      changeDirWidgetCommand = "fd --type d";
    };

    zoxide.enable = true;
    zoxide.enableNushellIntegration = true;

    yazi.enable = true;
    yazi.enableNushellIntegration = true;
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
