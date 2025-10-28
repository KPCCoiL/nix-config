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
    nnn
    rlwrap
    indent
    todo-txt-cli
    bitwarden-desktop
    outfieldr

    # Programming languages (listed here for casual use)
    sbcl
    guile
    cbqn
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
    userName = "KPCCoiL";
    userEmail = "4506345+KPCCoiL@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
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
      set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
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

  programs.qutebrowser = {
    enable = true;
    aliases = {
      q = "tab-close";
      "update-filter-list" = "spawn --userscript update-filter-list.sh";
      "add-arXiv" = "spawn --userscript add-arxiv.sh";
      "add-doi" = "spawn --userscript add-doi.sh";
      brave = "spawn --userscript open-in-brave.sh";
      webarchive = "spawn --userscript webarchive.sh";
    };
    searchEngines = {
      inspire = "https://inspirehep.net/literature?sort=mostrecent&size=100&page=1&q={}";
      nixpkgs = "https://search.nixos.org/packages?channel=unstable&query={}";
    };
    settings = {
      colors = {
        tabs = {
          even.bg = "#163852";
          odd.bg = "#282E23";
          selected = {
            even.bg = "#BB0000";
            odd.bg = "#DA0000";
          };
        };
      };
      fonts.default_size = "13pt";
      url.start_pages = "about:blank";
      tabs.last_close = "close";
      downloads.remove_finished = 5000;
      content.pdfjs = true;
    };
    extraConfig = ''
      import os
      import subprocess

      for mode in ['insert', 'caret']:
          config.bind('<Ctrl-l>', 'mode-leave', mode=mode)

      for mode in ['normal', 'caret']:
          config.bind('<Meta-d>', 'spawn --userscript open-dictionary.applescript', mode=mode)

      config.set('content.javascript.clipboard', 'access', 'github.com')

      path = subprocess.run(['${pkgs.bash}/bin/bash', '-i', '-c', 'echo $PATH'], capture_output=True)
      os.environ['PATH'] = path.stdout.decode()

      filters = []
      for filename in ['filters.txt', 'additional-filters.txt']:
          with open(config.configdir / filename) as f:
              filters += [l.strip()[1:-1] for l in f.readlines()]
      c.content.blocking.adblock.lists = filters
    '';
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
