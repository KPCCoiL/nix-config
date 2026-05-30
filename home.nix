{
  config,
  pkgs,
  pkgsUnstable,
  inputs,
  ...
}:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  imports = [
    ./vis
    ./qutebrowser
  ];

  home.packages = with pkgs; [
    # Daily tools
    nnn
    rlwrap
    indent
    todo-txt-cli
    bitwarden-desktop
    outfieldr
    unicodeit
    inputs.bsm.packages.${system}.default
    pkgsUnstable.gemini-cli
    pkgsUnstable.kardolus-chatgpt-cli
    pkgsUnstable.codex

    # Programming languages (listed here for casual use)
    sbcl
    guile
    cbqn
    (python3.withPackages (
      ps: with ps; [
        numpy
        matplotlib
        hy
      ]
    ))
    pforth
    # Until I figure out the proper way...
    julia-bin

    # Miscellaneous
    nixfmt-rfc-style
  ];

  home = {
    sessionPath = [
      "$HOME/.local/bin"
      "/opt/homebrew/bin"
    ];
    sessionVariables = {
      LSCOLORS = "gxfxcxdxbxegedabagacad";
      NNN_COLORS = "#a2a2a2a2";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      l = "ls -la";
      la = "ls -a";
      ll = "ls -la";
      info = "info --vi-keys";
      tldr = "tldr -L en --platform osx";
    };
    bashrcExtra = ''
      bind 'TAB:menu-complete'
      bind '"\e[Z": menu-complete-backward'
      bind "set show-all-if-ambiguous on"
      bind "set menu-complete-display-prefix on"
      bind -s 'set completion-ignore-case on'
      set_bash_prompt () {
          local last_status="''$?"
          if [[ ''$last_status -eq 0 ]]; then
              local status="\[\e[1;32m\]"
          else
              local status="\[\e[1;31m\]''$last_status "
          fi
          PS1="''${status}→ \[\e[1;36m\]\W \[\e[0m\]"
      }
      export PROMPT_COMMAND=set_bash_prompt
      n () {
          # Block nesting of nnn in subshells
          if [[ "''${NNNLVL:-0}" -ge 1 ]]; then
              echo "nnn is already running"
              return
          fi
          # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
          # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
          # see. To cd on quit only on ^G, remove the "export" and make sure not to
          # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
          #     NNN_TMPFILE="''${XDG_CONFIG_HOME:-''$HOME/.config}/nnn/.lastd"
          export NNN_TMPFILE="''${XDG_CONFIG_HOME:-''$HOME/.config}/nnn/.lastd"
          # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
          # stty start undef
          # stty stop undef
          # stty lwrap undef
          # stty lnext undef
          # The backslash allows one to alias n to nnn if desired without making an
          # infinitely recursive alias
          \nnn -A "''$@"
          if [ -f "''$NNN_TMPFILE" ]; then
                  . "''$NNN_TMPFILE"
                  rm -f "''$NNN_TMPFILE" > /dev/null
          fi
      }
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "CoiL";
      user.email = "coil@noreply.codeberg.org";
    };
    signing = {
      format = "openpgp";
      key = "1310798A35E32A5C";
      signByDefault = true;
    };
    includes = [
      {
        condition = "hasconfig:remote.*.url:https://github.com/**";
        contents = {
          user.name = "KPCCoiL";
          user.email = "4506345+KPCCoiL@users.noreply.github.com";
        };
      }
    ];
    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon\r\r"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
  };
  programs.gh.enable = true;

  programs.pay-respects.enable = true;
  programs.nix-index.enable = true;
  programs.fzf.enable = true;

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 10;
    historyLimit = 10000;
    terminal = "tmux-256color";
    sensibleOnTop = false;
    extraConfig = ''
      set -g set-titles on
      set -g set-titles-string "#W"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
      set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
      set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
    '';
  };

  programs.gpg.enable = true;
  programs.rbw = {
    package = pkgsUnstable.rbw;
    enable = true;
    settings = {
      email = "achitose@protonmail.com";
      pinentry = pkgs.pinentry_mac;
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.file.".todo.cfg".text = ''
    export TODO_DIR="$HOME/Dropbox/アプリ/2do.txt"
    export TODO_FILE="''$TODO_DIR/todo.txt"
    export DONE_FILE="''$TODO_DIR/done.txt"
    export REPORT_FILE="''$TODO_DIR/report.txt"
  '';
}
