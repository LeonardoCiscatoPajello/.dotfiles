{ config, pkgs, ... }:

{
  imports = [
# SHELL
    ./shell/termSh.nix

# HYPRLAND
      ./modules/hypr/hyprland.nix
      ./modules/hypr/waybar.nix
      ./modules/hypr/hyprlock.nix

# APPLICATIONS
      ./modules/app/rofi.nix
      ./modules/app/yazi.nix

# ESTHETICS
      ./modules/esthetics/wallpaper.nix
  ];

  home.username = "lcp";
  home.homeDirectory = "/home/lcp";
  home.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    hello
      firefox
      discord
      pavucontrol
      brightnessctl
      grim
      slurp
      wl-clipboard
      libnotify

# Addon for coding to be moved in a secon time
      ruby_3_3
      (python313.withPackages (ps: with ps; [
                               pip 
                               pyserial
                               paho-mqtt
                               mysql-connector
      ]))
      nodePackages.mermaid-cli
      sqlite
      clang-tools
      lua-language-server
      stylua
      ];

  home.sessionVariables = {
    EDITOR = "nvim";
    HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots/";
    GDK_CORE_DEVICE_EVENTS = "1";
  };

  home.pointerCursor = {
    package = pkgs.rose-pine-hyprcursor;
    name = "rose-pine";
    size = 24;
    hyprcursor.enable = true;
    gtk.enable = true;
    x11.enable = true;
  };

  my.wallpaper = {
    enable = true;
    image = "${config.home.homeDirectory}/Pictures/Back.jpg";
    monitors = [ "eDP-1" "HDMI-A-1" ];
  };

  programs.neovim = {
    enable = true; 
    extraPython3Packages = ps : [ ps.pynvim ];
  };

  programs.home-manager.enable = true;
} # ⟦ΔΒ⟧
