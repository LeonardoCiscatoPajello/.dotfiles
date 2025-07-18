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
    };
 };
}
