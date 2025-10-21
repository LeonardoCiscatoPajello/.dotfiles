{ config, pkgs, lib, ... }: 
let
palette = import ../esthetics/palette.nix;
c = palette.colors;
in {

  programs.mako = {
    enable = true;

    settings = {
# --- General ---
      font = "JetBrainsMono Nerd Font 11";
      layer = "overlay";                # keep above most windows
        anchor = "top-right";             # top-right corner
        margin = "20,20,0,0";             # top/right margins
        width = 380;
      height = 160;
      corner-radius = 14;
      padding = "10,16";
      border-size = 2;
      max-visible = 5;
      default-timeout = 5000;

# --- Colors ---
      background-color = c.bgAlt;
      text-color = c.fg;
      border-color = c.accent;
      progress-color = c.accent;

# --- Hover / urgency behaviors ---
      [urgency=low] = {
        border-color = c.borderInactive;
        text-color = c.fgAlt;
        background-color = c.bg;
      };
      [urgency=normal] = {
        border-color = c.accent;
        text-color = c.fg;
        background-color = c.bgAlt;
      };
      [urgency=high] = {
        border-color = c.error;
        text-color = c.fg;
        background-color = c.overlay;
      };
    };

# Optional service definition (for auto-start if not relying on DBus)
    service = {
      enable = true;
      command = "mako";
    };
  };
}# ⟦ΔΒ⟧
