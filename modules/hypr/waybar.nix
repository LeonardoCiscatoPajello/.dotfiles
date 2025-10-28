{ config, pkgs, lib, ... }:
let
palette = import ../esthetics/palette.nix;
c = palette.colors;

# Unified audio status script
audioStatusScript = pkgs.writeShellScript "waybar-audio-status" ''
set -euo pipefail
IFS=$'\n\t'
LC_ALL=C

mode="''${1:-sink}"  # sink | source
def="@DEFAULT_AUDIO_SINK@"
sec_start="Sinks:"
sec_stop="Sources:"
icon_mute=" "
icon_low=""
icon_mid=" "
icon_high=" "
icon_over=" "

if [ "$mode" = "source" ]; then
def="@DEFAULT_AUDIO_SOURCE@"
sec_start="Sources:"
sec_stop="Filters:"
icon_mute=" "
icon_low=""
icon_mid=""
icon_high=""
icon_over=""
fi

status="$(wpctl get-volume "$def" 2>/dev/null || true)"
if [ -z "$status" ]; then
[ "$mode" = "sink" ] && echo '{"text":" ?","class":"error","tooltip":"No default sink"}' && exit 0
echo '{"text":" ?","class":"error","tooltip":"No default source"}'
exit 0
fi

muted=0
case "$status" in *MUTED*) muted=1 ;; esac
vol="$(printf "%s" "$status" | awk '{print $2}')"
pct="$(awk -v v="$vol" 'BEGIN{ if (v+0<0) v=0; if (v>5) v=5; printf "%d", v*100+0.5 }')"

if [ "$muted" -eq 1 ] || [ "$pct" -eq 0 ]; then
icon="$icon_mute"; class="muted"
else
if   [ "$pct" -le 30 ]; then icon="$icon_low"; class="low"
elif [ "$pct" -le 70 ]; then icon="$icon_mid"; class="mid"
elif [ "$pct" -le 100 ]; then icon="$icon_high"; class="high"
else icon="$icon_over"; class="over"
fi
fi

star_line="$(wpctl status | awk -v s="$sec_start" -v e="$sec_stop" '
$0 ~ s {f=1;next}
$0 ~ e {f=0}
f && /\*/{print; exit}
')"
dev_name="$(printf "%s" "$star_line" | tr -d "│" | sed -E 's/.*\* *[0-9]+\.\s*//; s/\s*\[vol:.*//')"
[ -z "$dev_name" ] && dev_name="Unknown"

tip_title="$( [ "$mode" = "sink" ] && echo "Output" || echo "Input" )"
tooltip="$tip_title: $dev_name\nLevel: $pct%"
[ "$muted" -eq 1 ] && tooltip="$tooltip (muted)"
tooltip_esc="$(printf "%s" "$tooltip" | sed ':a;N;$!ba;s/\\/\\\\/g; s/\n/\\n/g; s/"/\\"/g')"

printf '{"text":"%s %s%%","class":"%s","tooltip":"%s"}\n' \
         "$icon" "$pct" "$class" "$tooltip_esc"
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
  levelSlider = pkgs.writeShellScript "waybar-level-slider" ''
  set -euo pipefail
  IFS=$'\n\t'

  mode="''${1:-sink}"  # sink | source | brightness

  case "$mode" in
  brightness)
  max=$(brightnessctl m 2>/dev/null || echo "")
  curRaw=$(brightnessctl g 2>/dev/null || echo "")
  [ -z "$max" ] || [ -z "$curRaw" ] && exit 0
cur=$(( curRaw * 100 / max ))
  ;;
  sink)
  cur=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%d", $2*100+0.5}')
  ;;
  source)
  cur=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | awk '{printf "%d", $2*100+0.5}')
  ;;
  *) exit 0 ;;
  esac

  list=""
  for p in $(seq 0 5 100); do
  line="$(${mkSliderBar} "$p")"
  if [ "$p" -eq "${cur:-0}" ]; then line="* $line"; else line="  $line"; fi
  list="$list$line"$'\n'
  done

  choice="$(printf "%s" "$list" | rofi -dmenu -p "$mode level" | sed 's/^* //;s/^  //')"
  [ -z "$choice" ] && exit 0
  sel=$(printf "%s" "$choice" | awk -F'%' '{print $1}' | awk '{print $NF}')
  [ -z "$sel" ] && exit 0

  if [ "$mode" = "brightness" ]; then
  brightnessctl set "$sel%" -q
  elif [ "$mode" = "sink" ]; then
  wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$sel%"
  pkill -USR2 waybar 2>/dev/null || true
  else
  wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ "$sel%"
  pkill -USR2 waybar 2>/dev/null || true
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
        spacing = 4;
        #output = [ "eDP-1" "HDMI-A-1" ];

        modules-left   = [ "hyprland/workspaces" "group/sel" ];
        modules-center = [ "clock" ];
        modules-right  = [ "tray" "network" "group/sys" ];

        backlight = {
          format = "{icon} ";
          interval = 2;
          "format-icons" = [ "󰃞" "󰃞" "󰃟" "󰃟" "󰃠" "󰃠" ];
          on-click-middle = "${levelSlider} brightness";
          on-scroll-up = "brightnessctl set 5%+ -q";
          on-scroll-down = "brightnessctl set 5%- -q";
        }; cpu = {
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

        "custom/volume" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec-if = "command -v wpctl >/dev/null";
          exec = "${audioStatusScript} sink";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          on-click-right = "${pickerScript} sink";
          on-click-middle = "${levelSlider} sink";
        };

        "custom/mic" = {
          interval = 2;
          return-type = "json";
          format = "{}";
          exec-if = "command -v wpctl >/dev/null";
          exec = "${audioStatusScript} source";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          on-scroll-up = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 5%-";
          on-click-right = "${pickerScript} source";
          on-click-middle = "${levelSlider} source";
        };

        "group/sel" = {
          orientation = "horizontal";
          modules = [ "custom/volume" "custom/mic" "backlight" ];
        };

        battery = {
          interval = 5;
          format = "{icon} {capacity}%";
          format-alt ="{icon} {capacity}% {time}";
          format-icons = [ "" "" "" "" "" ];
          states = { warning = 25; critical = 10; };
          tooltip-format = "Status: {status}\nPower: {power} W\nTime: {time}";
          on-click-right = "${pkgs.bash}/bin/bash -c 'if command -v powerprofilesctl >/dev/null; then cur=$(powerprofilesctl get); case $cur in performance) nxt=balanced;; balanced) nxt=power-saver;; power-saver) nxt=performance;; *) nxt=balanced;; esac; powerprofilesctl set \"$nxt\"; fi'";
        };
        "group/sys" = {
          orientation = "horizontal";
          modules = [ "cpu" "memory" "battery" ];
        };
      };
    };
    # === CSS STYLING OF WAYBAR ===
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

    window#waybar {
      background-color: transparent;
      border-bottom: none;
color: @fg;
padding: 6px 12px;
    }

    /* --- Workspaces --- */
#workspaces {
padding: 1px 10px;
margin: 0;
background: transparent;
transition: all 0.2s ease;
            border-radius: 16px;
border: 1px solid transparent;
}

#workspaces button{
border: none;
color: @fg;
       background-color: @bg;
padding: 1px 10px;
margin: 0;
        box-shadow: none;
}


#workspaces button:hover {
background: transparent;
border: 1px solid @accent2;
        border-radius: 16px;
}

#workspaces button:not(:last-child){
  margin-right: 4px;
}

#workspaces button.active{
color: @blueIce;
       font-weight: bold;
}
/* --- Bubble singoli --- */
#clock,
#tray,
#network {
  background-color: @bg;
color: @fg;
padding: 1px 10px;
margin: 0 6px;
        border-radius: 16px;
border: 1px solid @border;
        min-width: 38px;
}
#network:hover {
  background-color: @bg;
border: 1px solid @accent2;
}

/* --- Bubble gruppi --- */

#sys,
#sel {
  background-color: @bg;
  border-radius: 16px;
border: 1px solid @border;
padding: 1px 10px;
margin: 0 6px;
        min-width: 36px;
}

/* === STRUTTURA MODULO PER MODULO PADDING === */
#cpu {
padding: 1px 5px;
}
#battery {
padding: 1px 5px;
}
#memory {
padding: 1px 5px;
}

#custom-volume{
padding: 1px 5px;
}
#custom-mic{
padding: 1px 5px;
}
#backlight{
padding: 1px 5px;
         padding-right: 1px;
}


/* Hover sui gruppi */
#sel:hover,
#sys:hover {
  background-color: @bg;
  border-color: @accent2;
}

/* --- Stati & colori --- */

/* Audio */
#custom-volume.low,
#custom-mic.low { color: @fg-alt; }

#custom-volume.mid,
#custom-mic.mid { color: @fg-alt; border-color: @accent; }

#custom-volume.high,
#custom-mic.high { color: @accent2; }

#custom-volume.over { color: @warn; }

#custom-volume.muted,
#custom-mic.muted { color: @error; }

/* CPU & RAM */
#cpu { color: @accent2; }
#memory { color: @accent2; }
#cpu.warning, #memory.warning { color: @warn; }
#cpu.critical, #memory.critical { color: @error; }

/* Battery */
#battery { color: @blueIce; }
#battery.charging    { color: @ok; }
#battery.full        { color: @accent; }
#battery.warning { color: @warn; }
#battery.critical { color: @error; }
#battery.unknown     { color: @fg-alt; }

/* Network */
#network { color: @accent2; padding: 6px 10px; }

/* Tray */
#tray {
  margin-left: 6px;
  margin-right: 6px;
padding: 4px;
background: @bg;
border: none;
}

/* Clock */
#clock { color: @accent; }

/* Backlight */
#backlight { color: @blueIce; }
'';
};
} # ⟦ΔΒ⟧
