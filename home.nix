{ config, pkgs, ... }:

{
  imports = [

    # === SHELL ===
    ./shell/termSh.nix

    # === HYPRLAND ===
    ./modules/hypr/hyprland.nix
    ./modules/hypr/waybar.nix
    ./modules/hypr/hyprlock.nix
    ./modules/hypr/hypridle.nix

    # === SYSTEM ===
    ./modules/system/rofi.nix
    ./modules/system/yazi.nix
    ./modules/system/mako.nix

    # === APPS ===
    ./modules/apps/neovim.nix

    # === ESTHETICS ===
    ./modules/esthetics/wallpaper.nix
    ./modules/esthetics/cursor.nix

    # === PACKAGES ===
    ./modules/packages/gui.nix
    
  ];

  home.username = "lcp";
  home.homeDirectory = "/home/lcp";
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots/";
    GDK_CORE_DEVICE_EVENTS = "1";
  };

  my.wallpaper = {
    enable = true;
    image = "${config.home.homeDirectory}/Pictures/Back.jpg";
    monitors = [ "eDP-1" "HDMI-A-1" ];
  };

  programs.home-manager.enable = true;
} # ⟦ΔΒ⟧
