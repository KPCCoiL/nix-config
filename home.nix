{ config, pkgs, ... }:

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

  home.packages = with pkgs; [
    # Daily tools
    vis
    git
    gh
    nnn
    rlwrap
    indent
    todo-txt-cli
    bitwarden-desktop

    # Programming languages (listed here for casual use)
    sbcl
    guile
    (python3.withPackages (
      ps: with ps; [
        numpy
        matplotlib
      ]
    ))
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
      EDITOR = "vis";
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
      la = "la -a";
      ll = "ls -la";
      info = "info --vi-keys";
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

  programs.thefuck.enable = true;
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
      set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "      set -g status on"'
    '';
  };

  programs.gpg.enable = true;
  programs.rbw = {
    enable = true;
    settings = {
      email = "achitose@protonmail.com";
      pinentry = pkgs.pinentry_mac;
    };
  };

  programs.pubs = {
    enable = true;
    extraConfig = ''
      [main]

      pubsdir = ${config.home.homeDirectory}/MEGA/pubs
      docsdir = ${config.home.homeDirectory}/MEGA/pubs/doc

      doc_add = move

      open_cmd = open

      edit_cmd = ""

      note_extension = md

      max_authors = 3

      debug = False

      normalize_citekey = False

      citekey_format = {author_last_name:l}{year}{short_title:l}

      exclude_bibtex_fields = ,

      [formating]

      bold = True
      italics = True
      color = True


      [theme]
      # messages
      ok = green
      warning = yellow
      error = red

      # ui elements
      filepath = bold
      citekey = purple
      tag = cyan

      # bibliographic fields
      author = bold
      title = ""
      publisher = ""
      year = bold
      volume = bold
      pages = ""


      [plugins]
      active = alias,

      [[alias]]
      fzf = !pubs --force-colors list | fzf --ansi | sed -E 's/^\[([^ ]+)\] .*''$/\1/' | xargs pubs ''$@
      ofzf = !pubs fzf doc open

      [internal]
      # The version of this configuration file. Do not edit.
      version = 0.9.0
    '';
  };

  home.file.vis = {
    # Compromise: plugins are managed by vis-plug, which must be explicitly installed
    source = ./vis;
    target = ".config/vis";
    recursive = true;
  };

  home.file.".todo.cfg".text = ''
    export TODO_DIR="$HOME/Dropbox/アプリ/2do.txt"
    export TODO_FILE="''$TODO_DIR/todo.txt"
    export DONE_FILE="''$TODO_DIR/done.txt"
    export REPORT_FILE="''$TODO_DIR/report.txt"
  '';
}
