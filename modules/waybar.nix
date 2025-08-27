{ config, pkgs, lib, ... }:
let
  palette = import ../palette.nix;
  c = palette.colors;
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 10;
        output = [ "eDP-1" "HDMI-A-1" ];

        modules-left   = [ "hyprland/workspaces" "backlight" ];
        modules-center = [ "clock" ];
        modules-right  = [ "cpu" "memory" "tray" "battery" ];

        backlight = {
          # Uncomment and set if autodetect ever fails:
          # device = "amdgpu_bl0";
          format = "{icon} {percent}%";
          format-alt = "{percent}%";
          interval = 2;
          "format-icons" = [ "󰃞" "󰃟" "󰃠" "󰃠" "󰃠" ];
        };

        battery = {
          bat = "BAT0";
          adapter = "ADP1";
          format = "{icon} {capacity}%";
          format-charging = " {icon} {capacity}%";
          format-full = " {capacity}%";
          format-alt = "{capacity}%";
          "format-icons" = [ "" "" "" "" "" ];
          states = { warning = 25; critical = 10; };
          interval = 15;
          tooltip = true;
          tooltip-format = "{capacity}%\nState: {status}\nTime: {time}";
        };
      };
    };

    style = ''
      @define-color accent  ${c.accent};
      @define-color accent2 ${c.accent2};
      @define-color fg      ${c.fg};
      @define-color fg-alt  ${c.fgAlt};
      @define-color bg      ${c.bg};
      @define-color bg-alt  ${c.overlay};
      @define-color border  ${c.border};
      @define-color warn    ${c.warn};
      @define-color error   ${c.error};
      @define-color ok      ${c.ok};

      @define-color bgTrans rgba(16,16,20,0.88);

      * {
        font-size: 10px;
        min-height: 0;
        font-family: "JetBrainsMono Nerd Font", monospace;
      }

      window#waybar {
        background-color: @bgTrans;
        border-bottom: 1px solid @border;
        color: @fg;
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

      #clock { color: @accent; font-weight: 500; }

      #battery.warning  { color: @warn; }
      #battery.critical { color: @error; }
      #battery.charging { color: @ok; }

      #cpu, #memory, #backlight { color: @fg-alt; }

      #tray {
        background: @bg-alt;
        border: 1px solid @border;
        border-radius: 6px;
        padding: 0 4px;
      }
    '';
  };
} # ⟦ΔΒ⟧
