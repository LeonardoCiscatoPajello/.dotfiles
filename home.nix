{ config, pkgs, ... }:

{
  imports = [
    ./shell/termSh.nix
    ./modules/hypr/hyprland.nix
    ./modules/hypr/waybar.nix
    ./modules/app/rofi.nix
    ./modules/esthetics/wallpaper.nix
    ./modules/esthetics/hyprcursor.nix
  ];

  home.username = "lcp";
  home.homeDirectory = "/home/lcp";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  
  home.packages = with pkgs; [
    hello
    firefox
    discord
    hyprpaper
    pavucontrol
    libnotify
    grim
    slurp
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "MyHypr";
    HYPRCURSOR_THEME = "MyHypr";
    XCURSOR_SIZE = toString config.my.hyprcursor.size;
    HYPRCURSOR_SIZE = toString config.my.hyprcursor.size;
    GDK_CORE_DEVICE_EVENTS = "1";
  };

  programs.yazi = {
    enable = true;
    settings = {
      flavor = "ashen";
      opener.edit = [
        { run = "nvim \"$@\""; block = true; desc = "Edit with Neovim"; }
      ];
    };
  };
  
  my.hyprcursor.enable = true;

  my.wallpaper = {
    enable = true;
    image = "${config.home.homeDirectory}/Pictures/Back2.png";
    monitors = [ "eDP-1" "HDMI-A-1" ];
  };

  programs.home-manager.enable = true;
} # ⟦ΔΒ⟧
