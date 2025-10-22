{ config, pkgs, ...}:

let Aliases = {
  ll = "ls -Al";
  ".." = "cd ..";
  cp = "cp -i";
  dot = "cd ~/.dotfiles";
  conf = "cd ~/.config";
  uni = "cd ~/Documents/University";
  unia = "cd ~/.archive/UniArchive";
  ndot = "cd ~/.archive/.nvim/";
  h = "history";
  cl = "clear";
  nf = "neofetch";
  gs = "git status";
  gf = "git fetch";
  gp = "git push";
  gl = "git pull";
  ga = "git add .";
  gcmt = "git commit -a";
  delh = "truncate -s 0 ~/.zsh_history";
  hmsF = "home-manager switch --flake .";
  hm = "home-manager";
  swboot = "sudo /run/current-system/bin/switch-to-configuration boot";
  clgar = "sudo nix-collect-garbage -d";
  whybar = "GTK_DEBUG=interactive waybar";
};
in {
  imports = [
    ./promptln.nix
    ./kitty.nix
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
      shellAliases = Aliases;
      initContent= ''
        zmodload zsh/datetime
        zmodload zsh/mathfunc
        
        [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '
        bindkey '^P' history-beginning-search-backward
        bindkey '^N' history-beginning-search-forward

        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_ALL_DUPS
        setopt HIST_EXPIRE_DUPS_FIRST
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
