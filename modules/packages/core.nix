{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core tools
    neovim 
    wget 
    git 
    lazygit 
    tmux 
    fprintd 
    btop 
    neofetch 
    curl
    tree-sitter 
    ripgrep 
    fd 
    zip 
    unzip 
    fzf 
    zsh 
    bc 
    tree
    
    # Hyprland essentials
    wl-clipboard-rs 
    hyprlock 
    hyprcursor 
    rose-pine-hyprcursor
    greetd.tuigreet 
    socat 
    mako 
    hyprshot 
    hyprpaper 
    hypridle
    
    # Shell tools
    universal-ctags 
    shellcheck 
    shfmt
  ];
}# ⟦ΔΒ⟧
