{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # User apps
    firefox
    discord
    pavucontrol
    brightnessctl
    xournalpp
    dia #WARNING: Visual Paradigm substitute
    libreoffice-qt6
    
    # Wayland tools
    grim
    slurp
    wl-clipboard
    libnotify

    # JSON parser for hyprctl output
    jq
  ];
}# ⟦ΔΒ⟧
