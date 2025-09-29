{ config, pkgs, lib, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;
  wsNums = map toString (lib.lists.range 1 9) ++ [ "0" ];
  wsBinds = builtins.concatLists (map
  (n:
    let ws = if n == "0" then "10" else n;
    in [
      "$mod, ${n}, workspace, ${ws}"
      "$mod SHIFT, ${n}, movetoworkspace, ${ws}"
    ])
  wsNums);
in
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";

      monitor = [ 
        "HDMI-A-1,1920x1080@75,0x0,1" 
        "eDP-1, preferred, 1920x0,1"
      ];

      # Cleaned exec-once (start.sh removed, split combined command)
      exec-once = [
        "waybar"
      ];

      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 1;
        "col.active_border" = "rgba(c900ffff) rgba(330040ff) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes, please :)";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master.new_status = "master";

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = { natural_scroll = true; };
      };
      gestures.workspace_swipe = true;
      device = [
        {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        }
      ];

      bind =
        [
          "$mod, Q, exec, $terminal"
          "$mod, C, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, kitty -e yazi"
          "$mod, V, togglefloating,"
          "ALT, SPACE, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, up, togglesplit,"
          "$mod, F, exec, firefox"
          "$mod, D, exec, discord"
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
          "$mod, L, movefocus, l"
          "$mod, H, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"
          "$mod, mouse:272, movewindow"
          ]
        ++ wsBinds;

        wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
        # Full screen -> file
        ", Print, exec, grim $HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"

        # Region -> file
        "SHIFT, Print, exec, grim -g \"$(slurp)\" $HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"

        # Region -> clipboard
        "CTRL, Print, exec, grim -g \"$(slurp)\" - | wl-copy"

        # (Optional) Region -> annotate (swappy) -> save
        "SUPER_SHIFT, Print, exec, grim -g \"$(slurp)\" - | swappy -f -"

      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];

      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };
  };
} # ⟦ΔΒ⟧
