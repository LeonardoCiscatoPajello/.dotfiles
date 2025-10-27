{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # User apps
    firefox
    discord
    pavucontrol
    brightnessctl
    xournalpp
    
    # Wayland tools
    grim
    slurp
    wl-clipboard
    libnotify

    # JSON parser for hyprctl output
    jq
  ];
}# ⟦ΔΒ⟧
