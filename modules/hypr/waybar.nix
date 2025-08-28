{ config, pkgs, lib, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;

  # Volume script (default sink)
  volumeScript = pkgs.writeShellScript "waybar-volume" ''
    set -e
    status="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
    if [ -z "$status" ]; then
      echo '{"text":" ?","class":"error","tooltip":"No default sink"}'
      exit 0
    fi
    muted=0
    echo "$status" | grep -q MUTED && muted=1
    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{printf "%d", v*100+0.5}')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      icon=""; class="muted"
    else
      if   [ "$pct" -le 30 ]; then icon=""; class="low"
      elif [ "$pct" -le 70 ]; then icon=""; class="mid"
      elif [ "$pct" -le 100 ]; then icon=""; class="high"
      else icon=""; class="over"
      fi
    fi

    sinkLine="$(wpctl status | awk '/Sinks:/{f=1;next} /Sources:/{f=0} f && /\*/')"
    sinkName="$(printf "%s" "$sinkLine" | sed 's/.*\\*[^[]*\\[\\(.*\\)\\].*/\\1/')"
    [ -z "$sinkName" ] && sinkName="Unknown"

    tooltip="Output: $sinkName\nVolume: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$(printf "%s" "$tooltip" | sed 's/"/\\"/g')"
  '';

  # Mic script (default source)
  micScript = pkgs.writeShellScript "waybar-mic" ''
    set -e
    status="$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)"
    if [ -z "$status" ]; then
      echo '{"text":" ?","class":"error","tooltip":"No default source"}'
      exit 0
    fi
    muted=0
    echo "$status" | grep -q MUTED && muted=1
    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{printf "%d", v*100+0.5}')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      icon=""; class="muted"
    else
      icon=""
      if   [ "$pct" -le 30 ]; then class="low"
      elif [ "$pct" -le 70 ]; then class="mid"
      elif [ "$pct" -le 100 ]; then class="high"
      else class="high"
      fi
    fi

    srcLine="$(wpctl status | awk '/Sources:/{f=1;next} /Clients:/{f=0} f && /\*/')"
    srcName="$(printf "%s" "$srcLine" | sed 's/.*\\*[^[]*\\[\\(.*\\)\\].*/\\1/')"
    [ -z "$srcName" ] && srcName="Unknown"

    tooltip="Input: $srcName\nLevel: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$(printf "%s" "$tooltip" | sed 's/"/\\"/g')"
  '';

  # Device picker (sink | source)
  pickerScript = pkgs.writeShellScript "waybar-audio-picker" ''
    mode="$1"
    [ -z "$mode" ] && mode="sink"
    list="$(wpctl status)"
    if [ "$mode" = "sink" ]; then
      section="Sinks:"
      stop="Sources:"
    else
      section="Sources:"
      stop="Clients:"
    fi
    entries="$(printf "%s" "$list" | awk -v sec="$section" -v stop="$stop" '
      $0 ~ sec {f=1;next}
      $0 ~ stop {f=0}
      f && /^[[:space:]]*[0-9]+/ {
        id=$1
        line=$0
        mark=""
        if (line ~ /\*/) mark="*"
        gsub(/\*/, "", line)
        gsub(/^[[:space:]]+/, "", line)
        # extract bracketed description
        match(line, /\[.*\]/)
        if (RSTART>0) {
          desc=substr(line, RSTART+1, RLENGTH-2)
        } else {
          desc=line
        }
        print id "\t" mark desc
      }')"

    [ -z "$entries" ] && exit 0
    choice="$(echo "$entries" | rofi -dmenu -p "Select $mode")"
    [ -z "$choice" ] && exit 0
    id="$(printf "%s" "$choice" | cut -f1)"
    wpctl set-default "$id"
    if command -v notify-send >/dev/null; then
      notify-send "Audio" "Default $mode -> $id"
    fi
  '';
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

        modules-left   = [ "hyprland/workspaces" "backlight" "tray" ];
        modules-center = [ "clock" ];
        modules-right  = [ "custom/volume" "custom/mic" "cpu" "memory" "network" "custom/battery" ];

        backlight = {
          format = "{icon} ";
          interval = 2;
          "format-icons" = [ "󰃞" "󰃞" "󰃟" "󰃟" "󰃠" "󰃠" ];
        };

        # CPU & Memory enhanced (icons + states)
        cpu = {
          format = " {usage}%";
          interval = 2;
          states = { warning = 70; critical = 90; };
        };

        memory = {
          format = " {percentage}%";
            interval = 5;
          states = { warning = 70; critical = 85; };
        };

        network = {
          interval = 5;
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip = true;
          on-click = "${pkgs.kitty}/bin/kitty -e nmtui";
        };

        # Volume (output)
        "custom/volume" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${volumeScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          on-click-right = "${pickerScript} sink";
          on-click-middle = "pavucontrol &";
        };

        # Microphone (input)
        "custom/mic" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${micScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
          on-click-right = "${pickerScript} source";
          on-click-middle = "pavucontrol &";
        };

        "custom/battery" = {
          interval = 1;
          return-type = "json";
          format = "{}";
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
      @define-color blueIce ${c.blueIce};

      @define-color bgTrans rgba(16,16,20,0.88);

      * {
        font-size: 13px;
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

      #backlight { color: @blueIce; }

      #clock { color: @accent; font-weight: 500; }

      #cpu, #memory { color: @accent2; }
      #cpu.warning, #memory.warning { color: @warn; }
      #cpu.critical, #memory.critical { color: @error; }

      #network {
        color: @accent2;
        padding: 0 8px;
      }

      #custom-volume, #custom-mic {
        padding: 0 6px;
        color: @fg-alt;
      }
      #custom-volume.low, #custom-mic.low { color: @fg-alt; }
      #custom-volume.mid, #custom-mic.mid { color: @accent; }
      #custom-volume.high, #custom-mic.high { color: @accent2; }
      #custom-volume.over { color: @warn; }
      #custom-volume.muted, #custom-mic.muted { color: @error; }

      #tray {
        background: @bg-alt;
        border: 1px solid @border;
        border-radius: 6px;
        padding: 0 4px;
      }

      #custom-battery {
        padding: 0 6px;
        color: @blueIce;
      }
      #custom-battery.charging    { color: @ok; }
      #custom-battery.full        { color: @accent; }
      #custom-battery.discharging.warning { color: @warn; }
      #custom-battery.discharging.critical { color: @error; }
      #custom-battery.unknown     { color: @fg-alt; }
    '';
  };
}
