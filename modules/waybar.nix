{ config, pkgs, lib, ... }:
{
  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 10;
        output = [
          "eDP-1"
          "HDMI-A-1"
        ];
        modules-left = [ "hyprland/workspaces" "backlight" ]; # "tray"
        modules-center = [ "clock" ];
        modules-right = ["cpu" "memory" "tray" "battery" ]; # "network"
      };
    };
    style = '' 
    
      @define-color accent #190A04; 
      @define-color fg #4B4B46;
      @define-color bg #222C2D;
      @define-color bg-alt #1D2526;

    * {
      font-size: 11px;
      min-height: 0;
    }

    #mode {
      font-family: "JetBrainsMono Nerd Font";
      font-weight: bold;
      color: @accent;
    }
    
    window#waybar {
      background-color: @bg;
      border-bottom: 1px solid @bg-alt;
    }
    
    workspaces {
      font-family: "JetBrainsMono Nerd Font";
      border-bottom: 1px solid @bg-alt;
    }

    workspaces button {
      padding: 7px 12px 7px 12px;
      color: @fg;
      background-color: @bg;
      border: none;
    }
    
    workspaces button:hover {
      background: none;
      border: none;
      border-color: transparent;
      transition: none;
    }
    
    workspaces button.focused {
      border-radius: 0;
      color: @accent;
      font-weight: bold;
    }
'';

};
} # ⟦ΔΒ⟧
