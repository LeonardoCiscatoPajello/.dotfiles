{ config, pkgs, ...}:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;
in
{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      font = "JetBrainsMonoNL Nerd Font 14";
    };
    theme = "palette";
  };

  # Palette-based theme
  home.file.".config/rofi/palette.rasi".text = ''
    * {
      font: "JetBrainsMonoNL Nerd Font 14";
      background: ${c.bg};
      foreground: ${c.fg};
      selected-background: ${c.selectionBg};
      selected-foreground: ${c.selectionFg};
      accent: ${c.accent};
      accent2: ${c.accent2};
      border-color: ${c.border};
      spacing: 4px;
      padding: 6px;
    }

    window {
      background: @background;
      border: 2px solid;
      border-color: @accent;
      border-radius: 8px;
      padding: 8px;
    }

    mainbox { background: transparent; }

    listview {
      background: transparent;
      columns: 1;
      scrollbar: true;
      fixed-height: false;
    }

    element {
      background: transparent;
      text-color: @foreground;
      padding: 4px 6px;
      border-radius: 4px;
    }

    element selected {
      background: @selected-background;
      text-color: @selected-foreground;
      border: 1px solid; 
      border-color: @accent2;
    }
    element urgent { text-color: ${c.error}; }
    element active { text-color: ${c.ok}; }

    entry {
      background: ${c.overlay};
      text-color: @foreground;
      placeholder-color: ${c.fgAlt};
      expand: true;
      padding: 6px;
      border: 1px solid;
      border-color: @border-color;
      border-radius: 6px;
    }

    inputbar {
      background: transparent;
      children: [ entry ];
      spacing: 6px;
      padding: 0 4px 6px 4px;
    }

      message { background: transparent; }
      textbox { text-color: @foreground; }

    scrollbar {
      handle-color: @accent2;
      handle-width: 6px;
    }
  '';
} # ⟦ΔΒ⟧
