{ config, pkgs, lib, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;

  # Volume script (default sink) – patched
  volumeScript = pkgs.writeShellScript "waybar-volume" ''
    set -u

    get_status() {
      wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true
    }
    get_star_sink_line() {
      wpctl status | awk '/Sinks:/{f=1;next} /Sources:/{f=0} f && /\*/{print; exit}'
    }

    status="$(get_status)"
    if [ -z "$status" ]; then
      echo '{"text":" ?","class":"error","tooltip":"No default sink"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

    if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
      icon=""; class="muted"
    else
      if   [ "$pct" -le 30 ]; then icon=""; class="low"
      elif [ "$pct" -le 70 ]; then icon=""; class="mid"
      elif [ "$pct" -le 100 ]; then icon=""; class="high"
      else icon=""; class="over"
      fi
    fi

    sinkLine="$(get_star_sink_line)"
    sinkName="$(printf "%s" "$sinkLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$sinkName" ] && sinkName="Unknown"

    tooltip="Output: $sinkName\nVolume: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$tooltipEscaped"
  '';

  # Mic script (default source) – patched
  micScript = pkgs.writeShellScript "waybar-mic" ''
    set -u

    get_status() {
      wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true
    }

    get_star_source_line() {
      wpctl status | awk '/Sources:/{f=1;next} /Filters:/{f=0} f && /\*/{print; exit}'
    }

    status="$(get_status)"
    if [ -z "$status" ]; then
      echo '{"text":" ?","class":"error","tooltip":"No default source"}'
      exit 0
    fi

    muted=0
    if echo "$status" | grep -q 'MUTED'; then muted=1; fi

    vol="$(printf "%s" "$status" | awk '{print $2}')"
    pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

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

    srcLine="$(get_star_source_line)"
    srcName="$(printf "%s" "$srcLine" | tr -d '│' | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
    [ -z "$srcName" ] && srcName="Unknown"

    tooltip="Input: $srcName\nLevel: $pct%"
    [ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"

    tooltipEscaped="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

    printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
      "$icon" "$pct" "$class" "$tooltipEscaped"
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
      f && /^[[:space:]]*\*?[[:space:]]*[0-9]+\./ {
        line=$0
        gsub(/│/,"",line)
        # Trim leading space
        sub(/^[[:space:]]*/,"",line)
        mark=""
        if (substr(line,1,1)=="*") { mark="*"; sub(/^\*/,"",line); sub(/^[[:space:]]*/,"",line) }
        # Grab ID (up to first dot)
        id=line
        sub(/\..*/,"",id)
        # Device description (remove leading id + dot + spaces)
        desc=line
        sub(/^[0-9]+\.[[:space:]]*/,"",desc)
        # Cut off [vol: ...] part
        sub(/\[vol:.*$/,"",desc)
        gsub(/[[:space:]]+$/,"",desc)
        print id "\t" mark desc
      }')"

    if [ -z "$entries" ]; then
      command -v notify-send >/dev/null && notify-send "Audio" "No $mode devices parsed"
      exit 0
    fi
    if [ "$(printf "%s" "$entries" | wc -l)" -le 1 ]; then
      command -v notify-send >/dev/null && notify-send "Audio" "Only one $mode device"
      exit 0
    fi
    choice="$(echo "$entries" | rofi -dmenu -p "Select $mode")"
    [ -z "$choice" ] && exit 0
    id="$(printf "%s" "$choice" | cut -f1)"
    wpctl set-default "$id"
    command -v notify-send >/dev/null && notify-send "Audio" "Default $mode -> $id"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Slider helper (bar generator)
  mkSliderBar = pkgs.writeShellScript "gen-bar" ''
    # usage: gen-bar <percent>
    p=$1
    segs=20
    filled=$(( (p*segs)/100 ))
    [ $filled -gt $segs ] && filled=$segs
    bar="$(printf '%*s' "$filled" "" | tr ' ' '#')"
    unfilled=$(( segs - filled ))
    bar="$bar$(printf '%*s' "$unfilled" "" | tr ' ' '-')"
    printf "[%s] %3d%%" "$bar" "$p"
  '';

  # Output volume slider
  volumeSlider = pkgs.writeShellScript "waybar-volume-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Output Vol' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Mic volume slider
  micSlider = pkgs.writeShellScript "waybar-mic-slider" ''
    cur=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{print $2}')
    curPct=$(awk -v v="$cur" 'BEGIN{printf "%d", v*100+0.5}')
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Mic Level' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ "$sel%"
    pkill -USR2 waybar 2>/dev/null || true
  '';

  # Brightness slider
  brightnessSlider = pkgs.writeShellScript "waybar-brightness-slider" ''
    max=$(brightnessctl m 2>/dev/null)
    curRaw=$(brightnessctl g 2>/dev/null)
    [ -z "$max" ] || [ -z "$curRaw" ] && exit 0
    curPct=$(( curRaw * 100 / max ))
    list=""
    for p in $(seq 0 5 100); do
      line="$(${mkSliderBar} $p)"
      if [ "$p" -eq "$curPct" ]; then
        line="* $line"
      else
        line="  $line"
      fi
      list="$list$line"$'\n'
    done
    choice="$(printf "%s" "$list" | rofi -dmenu -p 'Brightness' | sed 's/^* //;s/^  //')"
    [ -z "$choice" ] && exit 0
    sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
    [ -z "$sel" ] && exit 0
    brightnessctl set "$sel%" -q
  '';
in
{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 8;
        output = [ "eDP-1" "HDMI-A-1" ];

        modules-left   = [ "hyprland/workspaces" "backlight" "group/audio" ];
        modules-center = [ "clock" ];
        modules-right  = [ "tray" "group/sys"  "network" "custom/battery" ];

        backlight = {
          format = "{icon} ";
          interval = 2;
          "format-icons" = [ "󰃞" "󰃞" "󰃟" "󰃟" "󰃠" "󰃠" ];
          on-click-middle = "${brightnessSlider}";
          on-scroll-up = "brightnessctl set 5%+ -q";
          on-scroll-down = "brightnessctl set 5%- -q";
        };

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

        "group/sys" = {
          orientation = "horizontal";
          modules = [ "cpu" "memory" ];
        };

        network = {
          interval = 5;
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  Disconnected";
          tooltip = true;
          on-click = "${pkgs.kitty}/bin/kitty -e nmtui";
        };

        "custom/volume" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${volumeScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          on-click-right = "${pickerScript} sink";
          on-click-middle = "${volumeSlider}";
        };

        "custom/mic" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec = "${micScript}";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
          on-click-right = "${pickerScript} source";
          on-click-middle = "${micSlider}";
        };

        "group/audio" = {
          orientation = "horizontal";
          modules = [ "custom/volume" "custom/mic" ];
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
      @define-color bg-alt  ${c.blackBright};
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

      /* Minimal bar; let modules appear as bubbles */
      window#waybar {
        background-color: transparent;
        border-bottom: none;
        color: @fg;
        padding: 6px 12px;
      }

      /* Workspaces */
      workspaces button {
        padding: 6px 10px;
        color: @fg;
        background: transparent;
        border: none;
        border-radius: 8px;
      }
      workspaces button.focused {
        color: @accent;
        font-weight: bold;
        background: @bg-alt;
      }
      workspaces button:hover {
        background: @bg-alt;
      }

      /* Bubble modules */
      #clock,
      #tray,
      #backlight,
      #network,
      #custom-battery {
        background-color: @bg-alt;
        color: @fg;
        padding: 6px 10px;
        margin: 0 6px;
        border-radius: 16px;
        border: 1px solid @border;
        min-width: 38px;
      }

      /* Bubble groups */
      #group-sys,
      #group-audio
      #group-sys > box,
      #group-audio > box {
        background-color: @bg-alt;
        color: @fg;
        padding: 6px 10px;
        margin: 0 6px;
        border-radius: 16px;
        border: 1px solid @border;
        min-width: 38px;
      }

      /* Make inner modules transparent and spaced */
      #group-audio > *,
      #group-sys  > * {
       background-color: transparent;
       border: none;
       padding: 0 8px;      /* inner spacing */
       margin: 0 2px;
      }

      /* Hover: subtle color change */
      #backlight:hover,
      #network:hover,
      #custom-battery:hover {
        background-color: @bg;
        border-color: @border;
      }

      /* Hover: Bubbles-Groups */
      #group-audio:hover,
      #group-sys:hover,
      #group-audio > box:hover,
      #group-sys > box:hover {
        background-color: @bg;
        border-color: @border;
      }

      /* State colors */
      #custom-volume.low,
      #custom-mic.low { color: @fg-alt; border-color: @border; }

      #custom-volume.mid,
      #custom-mic.mid { color: @fg-alt; border-color: @accent; }

      #custom-volume.high,
      #custom-mic.high { color: @accent2; border-color: @accent2; }

      #custom-volume.over { color: @warn; border-color: @warn; }

      #custom-volume.muted,
      #custom-mic.muted { color: @error; border-color: @error; }

      /* CPU & memory states */
      #cpu { color: @accent2; }
      #memory { color: @accent2; }
      #cpu.warning, #memory.warning { color: @warn; }
      #cpu.critical, #memory.critical { color: @error; }

      /* Network */
      #network { color: @accent2; padding: 6px 10px; }

      /* Tray */
      #tray {
        margin-left: 8px;
        margin-right: 6px;
        padding: 4px;
        background: transparent;
        border: none;
      }

      /* Clock */
      #clock{ color: @accent; }

      /* Backlight */
      #backlight { color: @blueIce; }

      /* Battery state coloring (keep your semantics) */
      #custom-battery { color: @blueIce; }
      #custom-battery.charging    { color: @ok; }
      #custom-battery.full        { color: @accent; }
      #custom-battery.discharging.warning { color: @warn; }
      #custom-battery.discharging.critical { color: @error; }
      #custom-battery.unknown     { color: @fg-alt; }
    '';
  };
} # ⟦ΔΒ⟧
