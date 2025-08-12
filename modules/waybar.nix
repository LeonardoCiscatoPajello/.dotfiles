{ config, pkgs, ... }:
{
programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" "tray" ];
        modules-center = [ "clock" ];
        modules-right = ["cpu" "memory" "network" "battery" ];
      };
    };
    style = '' 
    * {
        font-family: "JetBrains", monospace;
        font-size: 11px;
      }
    '';
  };
} # ⟦ΔΒ⟧
