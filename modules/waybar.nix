{ config, pkgs, ... }:
{
programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin-bottom = -10;
        spacing = 0;
        modules-left = [ "hyprland/workspaces" "tray" ];
        modules-center = [ "clock" ];
        modules-right = ["cpu" "memory" "network" "battery" ];
      };
    };
    style = '' 
    window#waybar { background: red !important; }
    '';
  };
} # ⟦ΔΒ⟧
