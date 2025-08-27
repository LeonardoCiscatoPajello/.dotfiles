{ config, pkgs, lib, ... }:
let
  palette = import ../palette.nix;
  c = palette.colors;
in 
{
  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 10;
        output = ["eDP-1" "HDMI-A-1"];
        modules-left = [ "hyprland/workspaces" "backlight" ]; # "tray"
        modules-center = [ "clock" ];
        modules-right = ["cpu" "memory" "tray" "battery" ]; # "network"
      };
    };
    style = ''
      @define-color accent ${c.accent};
      @define-color accent2 ${c.accent2};
      @define-color fg ${c.fg};
      @define-color fg-alt ${c.fgAlt};
      @define-color bg ${c.bg};
      @define-color bg-alt ${c.overlay};
      @define-color border ${c.border};
      @define-color warn ${c.warn};
      @define-color error ${c.error};
      @define-color ok ${c.ok};

      * {
        font-size: 11px;
        min-height: 0;
        font-family: JetBrainsMono Nerd Font;
      }

      window#waybar {
        background-color: @bg;
        border-bottom: 1px solid @border;
        color: @fg;
      }

      #mode {
        font-weight: bold;
        color: @accent;
      }

      workspaces {
        border-bottom: 1px solid @border;
      }

      workspaces button {
        padding: 6px 10px;
        color: @fg;
        background: transparent;
        border: none;
      }

      workspaces button.focused {
        color: @accent;
        font-weight: bold;
        background: @bg-alt;
      }

      workspaces button:hover {
        background: @bg-alt;
      }

      #clock {
        color: @accent;
        font-weight: 500;
      }

      #battery.warning {
        color: @warn;
      }
      #battery.critical {
        color: @error;
      }
      #battery.charging {
        color: @ok;
      }

      #cpu, #memory {
        color: @fg-alt;
      }

      #tray {
        background: @bg-alt;
        border: 1px solid @border;
        border-radius: 6px;
        padding: 0 4px;
      }
    '';
  };
} # ⟦ΔΒ⟧
