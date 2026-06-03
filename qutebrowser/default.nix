{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  prefix = "_qute-";
  userscripts = pkgs.callPackages ./userscripts {
    inherit prefix;
    bsm = inputs.bsm.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  uexe = name: "${userscripts.${name}}/bin/${prefix + name}";
in
{
  home.packages = lib.attrsets.attrValues userscripts;
  programs.qutebrowser = {
    enable = true;
    # qutebrowser from Homebrew provides overall better experience on darwin
    package = pkgs.emptyDirectory;
    aliases = {
      q = "tab-close";
      "update-filter-list" = "spawn --userscript ${uexe "update-filter-list"}";
      bsm = "spawn --userscript ${uexe "bsmadd"}";
      brave = "spawn --userscript ${uexe "open-in-brave"}";
      webarchive = "spawn --userscript ${uexe "webarchive"}";
    };
    searchEngines = {
      i = "https://inspirehep.net/literature?sort=mostrecent&size=100&page=1&q={}";
      nixpkgs = "https://search.nixos.org/packages?channel=unstable&query={}";
    };
    keyBindings = builtins.foldl' pkgs.lib.recursiveUpdate { } [
      {
        insert."<Meta+l>" = "spawn --userscript ${uexe "rbw"}";
      }
      (pkgs.lib.genAttrs [ "insert" "caret" ] (_: {
        "<Ctrl+l>" = "mode-leave";
      }))
      (pkgs.lib.genAttrs [ "normal" "caret" ] (_: {
        "<Meta+d>" = "spawn --userscript ${uexe "open-dictionary"}";
      }))
    ];
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
    perDomainSettings = {
      "github.com".content.javascript.clipboard = "access";
    };
    extraConfig = ''
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
}
