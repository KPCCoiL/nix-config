{ config, pkgs, ... }:
{
  programs.qutebrowser = {
    enable = true;
    # qutebrowser from Homebrew provides overall better experience on darwin
    package = pkgs.emptyDirectory;
    aliases = {
      q = "tab-close";
      "update-filter-list" = "spawn --userscript update-filter-list.sh";
      "add-arXiv" = "spawn --userscript add-arxiv.sh";
      "add-doi" = "spawn --userscript add-doi.sh";
      brave = "spawn --userscript open-in-brave.sh";
      webarchive = "spawn --userscript webarchive.sh";
    };
    searchEngines = {
      i = "https://inspirehep.net/literature?sort=mostrecent&size=100&page=1&q={}";
      nixpkgs = "https://search.nixos.org/packages?channel=unstable&query={}";
    };
    keyBindings.insert."<Meta+l>" = "spawn --userscript rbw.sh";
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
      tabs = {
        last_close = "close";
        position = "left";
        width = "25%";
        show = "switching";
        show_switching_delay = 900;
      };
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
    greasemonkey = [
      (pkgs.writeText "overleaf-vim.js" ''
        // ==UserScript==
        // @name         Overleaf Editor Custom VIM Keybindings
        // @namespace    http://tampermonkey.net/
        // @version      0.1
        // @match        https://www.overleaf.com/project/*
        // @grant        none
        // ==/UserScript==

        (function() {
            'use strict';

            // On Overleaf editor window.addEventListener != undefined for some reason
            // The qutebrowser grasemonkey wrapper is fooled by this, so we need unsafeWindow
            unsafeWindow.addEventListener("UNSTABLE_editor:extensions", (event) => {
                const { CodeMirror, CodeMirrorVim, extensions } = event.detail;

                for (let mode of ['insert', 'visual']) {
                    CodeMirrorVim.Vim.noremap("<C-l>", "<Esc>", mode);
                }
                for (let mode of ['normal', 'visual']) {
                    CodeMirrorVim.Vim.noremap("j", "gj", mode);
                    CodeMirrorVim.Vim.noremap("k", "gk", mode);
                }
                CodeMirrorVim.Vim.noremap("Y", "y$", "normal");
            });
        })();
      '')
    ];
  };
  home.file.".qutebrowser/userscripts".source = ./userscripts;
}
