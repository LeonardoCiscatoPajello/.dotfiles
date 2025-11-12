{ config, pkgs, ... }:
let 
  palette = import ../modules/esthetics/palette.nix;
  c = palette.colors;
in
{
  programs.kitty = {
      enable = true;
      extraConfig = ''
        # Basics
        font_family JetBrainsMonoNL Nerd Font
        font_size 12
        background_blur 1 
        background_opacity 0.92
        
        foreground              ${c.fg}
        background              ${c.bg}
        selection_foreground    ${c.selectionFg}
        selection_background    ${c.selectionBg}

        cursor                  ${c.cursor}
        cursor_text_color       ${c.bg}

        # ANSI (normal)
        color0  ${c.black}
        color1  ${c.red}
        color2  ${c.green}
        color3  ${c.yellow}
        color4  ${c.blue}
        color5  ${c.magenta}
        color6  ${c.cyan}
        color7  ${c.white}

        # ANSI (bright)
        color8  ${c.blackBright}
        color9  ${c.redBright}
        color10 ${c.greenBright}
        color11 ${c.yellowBright}
        color12 ${c.blueBright}
        color13 ${c.magentaBright}
        color14 ${c.cyanBright}
        color15 ${c.whiteBright}

        # Optional: tab bar / border accents
        tab_bar_background      ${c.bgAlt}
        active_tab_foreground   ${c.bg}
        active_tab_background   ${c.accent}
        inactive_tab_foreground ${c.fgAlt}
        inactive_tab_background ${c.overlay}

        # URL / link styling
        url_color ${c.accent2}

        # Improve legibility of bold & italic
        bold_font auto
        bold_italic_font auto
        show_hyperlink_targets yes

        allow_remote_control yes
      '';
    };
} # ⟦ΔΒ⟧
