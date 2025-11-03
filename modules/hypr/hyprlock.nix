{ config, ... }:
let
wallpaperPath = "${config.home.homeDirectory}/Pictures/lock.png";
in
{
  home.file.".config/hypr/hyprlock.conf".text = ''
# ===== Palette (from modules/esthetics/palette.nix) =====
    $fg        = rgba(228,223,217,1.0)   # c.fg        #E4DFD9
    $bg        = rgba(16,16,20,0.92)     # c.bg        #101014 (slightly translucent)
    $overlay   = rgba(34,38,44,0.75)     # c.overlay   #22262C
    $accent    = rgba(201,165,66,1.0)    # c.accent    #C9A542 (yellow)
    $accent2   = rgba(188,74,124,1.0)    # c.accent2   #BC4A7C (magenta)
    $focus     = rgba(123,73,174,1.0)    # c.purpleBright #7B49AE
    $blueIce   = rgba(95,169,230,1.0)    # c.blueIce   #5FA9E6
    $ok        = rgba(110,143,73,1.0)    # c.ok        #6E8F49
    $error     = rgba(166,70,62,1.0)     # c.error     #A6463E

# ==== Other colors possible for config ====


    $primary_4_rgba = rgba(212,131,203,0.9)       # #D483CB
    $primary_3_rgba = rgba(104,116,206,0.9)       # #6874CE
    $p3_accent_6_rgba = rgba(122,131,194,0.9)     # #7A83C2
    $p2_accent_4_rgba = rgba(100,87,143,0.9)      # #64578F
    $p3_accent_7_rgba = rgba(154,163,230,0.9)     # #9AA3E6
    $text_1_rgba = rgba(255,255,255,0.9)          # #FFFFFF

# variables
    $fn_splash=echo "Yes, indeed..." #"$(hyprctl splash)"
    $wall = ${wallpaperPath}

# BACKGROUND
  background {
    monitor =
      path = $wall
# path = screenshot
      blur_passes = 3 # 0 disables blurring
      blur_size = 2
      noise = 0.0117
      contrast = 0.8916
      brightness = 0.8172
      vibrancy = 0.1696
      vibrancy_darkness = 0.0
  }

# TIME
  label {
    monitor =
# text = cmd[update:1000] echo "$(date +"%-I:%M%p")"
# text = cmd[update:1000] echo "$(date +"%H:%M")"
      text = $TIME
      color = $primary_4_rgba #nil
      font_size = 200
      font_family = JetBrains Mono Nerd Font Mono ExtraBold
      position = 0, 300
      halign = center
      valign = center
  }

# DATE
  label {
    monitor =
      text = cmd[update:1000] echo "$(date +"%B %d %Y")"
      color = $p3_accent_6_rgba #nil
      font_size = 40
      font_family = JetBrains Mono Nerd Font Mono Bold
      position = 0, 50
      halign = center
      valign = center
  }

# DAY
label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%A")"
    color = $p2_accent_4_rgba #nil
    font_size = 40
    font_family = JetBrains Mono Nerd Font Mono Bold
    position = 550, 180
    halign = center
    valign = center
}

# GENERAL
  general {
    no_fade_in = false
      grace = 0
      disable_loading_bar = true
  }

  $fn_greet=echo "Good $(date +%H | awk '{if ($1 < 10) print "morning"; else if ($1 < 13) print "noon"; else if ($1 < 18) print "afternoon"; else if ($1 < 22) print "evening"; else print "night"}'), $(echo "Leonardo"")" #| tr '[:lower:]' '[:upper:]')"

# USER
    label {
      monitor =
#text = cmd[update:60000] echo "Good $(date +"%-I" | awk '{if ($1 < 12) print "morning"; else print "evening"}') $(echo ''${USER} | tr '[:lower:]' '[:upper:]' )"
        text = cmd[update:60000] $fn_greet
        color = $p3_accent_7_rgba #nil
        font_size = 30
        font_family = JetBrains Mono Nerd Font Mono Bold
        position = 0, -400
        halign = center
        valign = center
    }

# INPUT FIELD
  input-field {
    monitor =
      size = 200, 50
      outline_thickness = 3
      dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = true
      dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
      outer_color = $p2_accent_4_rgba #$overlay
      inner_color = $p3_accent_6_rgba #$bg
      font_color = $text_1_rgba       #$fg
      fade_on_empty = true
      fade_timeout = 1000 # Milliseconds before fade_on_empty is triggered.
      placeholder_text = <i>  Logged in as </i>$USER
      hide_input = false
      rounding = -1 # -1 means complete rounding (circle/oval)
      fail_color = $error # if authentication failed, changes outer_color and fail message color
      fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i> # can be set to empty
      fail_transition = 300 # transition time in ms between normal outer_color and fail_color
      capslock_color = 1
      numlock_color = 1
      bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
      invert_numlock = false # change color if numlock is off
      swap_font_color = true # see below
      position = 0, -130
      halign = center
      valign = center
  }

# SPLASH
#label {
#    monitor =
#    text = cmd[update:1000] $fn_splash
#    color = $fg
#    font_family = JetBrainsMono, Font Awesome 6 Free Solid
#    position = 0, 0
#    halign = center
#    valign = bottom
#}
  '';
} # ⟦ΔΒ⟧
