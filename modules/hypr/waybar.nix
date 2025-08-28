{ config, pkgs, lib, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;
in
{
  programs.waybar = {
    enable = true;
    # Optional: uncomment for automatic user service
    # systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 10;
        output = [ "eDP-1" "HDMI-A-1" ];

        modules-left   = [ "hyprland/workspaces" "backlight" ];
        modules-center = [ "clock" ];
        modules-right  = [ "cpu" "memory" "tray" "custom/battery" ];

        backlight = {
          format = "{icon} ";
          # format-alt = "{icon} {percent}%"; momentaneamente tolto per semplicita'
          interval = 2;
          "format-icons" = [ "󰃞" "󰃞" "󰃟" "󰃟" "󰃠" "󰃠" ];
        };

        "custom/battery" = {
          interval = 1;
          return-type = "json";
          format = "{}";

          # Right-click: cycle power profile
          on-click-right = "${pkgs.bash}/bin/bash -c 'if command -v powerprofilesctl >/dev/null; then cur=$(powerprofilesctl get); case $cur in performance) nxt=balanced;; balanced) nxt=power-saver;; power-saver) nxt=performance;; *) nxt=balanced;; esac; powerprofilesctl set \"$nxt\"; fi'";

          exec = ''
            ${pkgs.bash}/bin/bash -c '
              cap_file=/sys/class/power_supply/BAT0/capacity
              status_file=/sys/class/power_supply/BAT0/status
              if [ -r "$cap_file" ]; then cap=$(cat "$cap_file"); else cap="?"; fi
              if [ -r "$status_file" ]; then st=$(cat "$status_file"); else st="Unknown"; fi

              icon=""
              if [ "$cap" != "?" ]; then
                [ "$cap" -gt 15 ] && icon=""
                [ "$cap" -gt 35 ] && icon=""
                [ "$cap" -gt 60 ] && icon=""
                [ "$cap" -gt 85 ] && icon=""
              fi
              case "$st" in
                Charging) icon="" ;;
                Full) icon="" ;;
              esac

              classes=$(echo "$st" | tr "A-Z" "a-z")
              if [ "$cap" != "?" ]; then
                if [ "$cap" -le 10 ]; then classes="$classes critical"
                elif [ "$cap" -le 25 ]; then classes="$classes warning"
                fi
              fi

              profile=""
              if command -v powerprofilesctl >/dev/null; then
                profile=$(powerprofilesctl get 2>/dev/null)
              fi

              tooltip="Status: $st"
              [ -n "$profile" ] && tooltip="$tooltip\nProfile: $profile"

              printf '"'"'{"text":"%s %s%%","tooltip":"%s","class":"%s","alt":"%s"}\n'"'"' \
                "$icon" "$cap" "$(printf %s "$tooltip" | sed '"'"'s/"/\\"/g'"'"')" "$classes" "$profile"
            '
          '';
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

      #cpu, #memory, #backlight { color: @fg-alt; }

      #tray {
        background: @bg-alt;
        border: 1px solid @border;
        border-radius: 6px;
        padding: 0 4px;
      }

      #custom-battery {
        padding: 0 6px;
      }
      #custom-battery.charging    { color: @ok; }
      #custom-battery.full        { color: @accent; }
      #custom-battery.discharging.warning { color: @warn; }
      #custom-battery.discharging.critical { color: @error; }
      #custom-battery.unknown     { color: @fg-alt; }
    '';
  };
} # ⟦ΔΒ⟧
