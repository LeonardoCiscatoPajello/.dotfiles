{ config, pkgs, ...}:

let Aliases = {
  ll = "ls -Al";
  ".." = "cd ..";
  cp = "cp -i";
  dot = "cd ~/.dotfiles";
  conf = "cd ~/.config";
  h = "history";
  cl = "clear";
};
in {
  imports = [
    ./promptln.nix
  ];

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = Aliases;
    };

    zsh = { 
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = Aliases;
      initExtra = ''
        zmodload zsh/datetime
        zmodload zsh/mathfunc
        
        [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '
        bindkey '^P' history-beginning-search-backward
        bindkey '^N' history-beginning-search-forward

        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_EXPIRE_DUPS_FIRST
      '';

      #oh-my-zsh = {
       # enable = false;
        #theme = "half-life"; #strug nanotech
        #  plugins = [ "git" ];
      #};
    };

    kitty = {
      enable = true;
      extraConfig = ''
        show_hyperlink_targets yes
        font_family JetBrainsMonoNL Nerd Font
        font_size 10
        background_blur 1
        background_opacity 0.37


        cursor                  #F5E0DC
        cursor_text_color       #1E1E2E

        url_color               #F5E0DC

        active_border_color     #B4BEFE
        inactive_border_color   #6C7086
        bell_border_color       #F9E2AF

        wayland_titlebar_color system
        macos_titlebar_color system

        active_tab_foreground   #11111B
        active_tab_background   #CBA6F7
        inactive_tab_foreground #CDD6F4
        inactive_tab_background #181825
        tab_bar_background      #11111B

        mark1_foreground #1E1E2E
        mark1_background #B4BEFE
        mark2_foreground #1E1E2E
        mark2_background #CBA6F7
        mark3_foreground #1E1E2E
        mark3_background #74C7EC
        
        # black
        color0 #45475A
        color8 #585B70

        # red
        color1 #F38BA8
        color9 #F38BA8
        
        # green
        color2  #00FF7F
        color10 #00FF7F
        
        # yellow 
        color3  #FF7733
        color11 #FF7733
        
        # blue
        color4  #89B4FA
        color12 #89B4FA
        
        #magenta
        color5  #D183E8
        color13 #D183E8
        
        # cyan
        color6  #94E2D5
        color14 #94E2D5
        
        # white
        color7  #BAC2DE
        color15 #A6ADC8

        '';
    };

    tmux = {
      enable = true;
      shortcut = "s";
      terminal = "tmux-256color";
      extraConfig = ''
        unbind r
        bind r source-file ~/.config/tmux.conf

        set -ag terminal-overrides ",zterm-256color:RGB"

        set -g mouse on
        set-window-option -g mode-keys vi

        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        set-option -g status-position top

        bind | split-window -h 
        bind _ split-window -v

        bind -r < resize-pane -L 5
        bind -r > resize-pane -R 5
        bind -r + resize-pane -U 5
        bind -r - resize-pane -D 5
        '';
    };
  };
} # ⟦ΔΒ⟧
