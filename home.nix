{ config, pkgs, ... }:

{
  imports = [
    ./shell/termSh.nix
    ./modules/hypr/hyprland.nix
    ./modules/hypr/waybar.nix
    ./modules/app/rofi.nix
    ./modules/esthetics/wallpaper.nix
  ];

  home.username = "lcp";
  home.homeDirectory = "/home/lcp";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    hello
    firefox
    discord
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
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

  my.wallpaper = {
    enable = true;
    image = "${config.home.homeDirectory}/Pictures/Back.jpg";
    monitors = [ "eDP-1" "HDMI-A-1" ];
  };

  programs.home-manager.enable = true;
} # ⟦ΔΒ⟧
