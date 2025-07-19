{ config, pkgs, ...}:

let Aliases = {
  ll = "ls -Al";
  ".." = "cd ..";
  cp = "cp -i";
  dot = "cd ~/.dotfiles";
  conf = "cd ~/.config";
  h = "history";
};
in {
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

      oh-my-zsh = {
        enable = true;
        theme = "nanotech"; #strug half-life
        plugins = [ "git" ];
      };
    };

    kitty = {
      enable = true;
      extraConfig = ''
        show_hyperlink_targets yes
        font_family JetBrainsMonoNL Nerd Font
        font_size 10
        background_blur 1
        background_opacity 0.37
      '';
    };
 };
} # ⟦ΔΒ⟧
