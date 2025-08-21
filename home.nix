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
    tmux
    git
    nnn
    fzf
    rlwrap

    # Programming languages (listed here for casual use)
    sbcl
    guile
    (python3.withPackages (ps: with ps; [ numpy matplotlib ]))
    # Until I figure out the proper way...
    julia-bin


    # Academic stuffs
    pubs
    texliveFull

    # Miscellaneous
    nixfmt-rfc-style
    thefuck
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}