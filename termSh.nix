{ config, pkgs, ...}:

let Aliases = {
  ll = "ls -Al";
  ".." = "cd ..";
  cp = "cp -i";
  dotfiles = "cd ~/.dotfiles";
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
        theme = "half-life";
        plugins = [ "git" ];
      };
    };

    kitty = {
      enable = true;
      extraConfig = ''
        font_family JetBrainsMonoNL Nerd Font
        font_size 10
        background_blur 1
        background_opacity 0.37
      '';
    };
 };
}
