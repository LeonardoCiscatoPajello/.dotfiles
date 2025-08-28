{ config, lib, ... }:
let 
  cfg = config.my.wallpaper;
  inherit (lib) mkOption mkEnableOption types mkIf;
in
{
  options.my.wallpaper = {
    enable = mkEnableOption "Simple hyprpaper management";
    image = mkOption {
      type = types.path;
      description = "Path to the wallpaper img.";
    };
    monitors = mkOption {
      type = types.listOf types.str;
      default = [ "eDP-1" "HDMI-A-1" ];
      description = "List of monitors.";
    }; 
  };

  config = mkIf cfg.enable {
    home.file.".config/hypr/hyprpaper.conf".text =
      let
        lines =
          [ "preload = ${cfg.image}" ]
          ++ (map (m: "wallpaper = ${m},${cfg.image}") cfg.monitors);
      in builtins.concatStringsSep "\n" lines;

    # Append hyprpaper to exec-once 
    wayland.windowManager.hyprland.settings.exec-once =
      lib.mkAfter [ "hyprpaper" ];
  };
} # ⟦ΔΒ⟧
