{ config, pkgs, ... }:
{
  programs = {
    kitty = {
      extraConfig = ''
        show_hyperlink_targets yes
        font_family JetBrainsMonoNL Nerd Font
        font_size 10
        background_blur 1
        background_opacity 0.37
        
        foreground              #F7ECFC
        background              #100513
        selection_foreground    #100513
        selection_background    #BC4A7C

        cursor                  #BC4A7C
        cursor_text_color       #100513

        # Black
        color0  #100513
        color8  #270925

        # Red
        color1  #A64449
        color9  #A64449

        # Green (soft purple for harmony)
        color2  #2C0935
        color10 #2C0935

        # Yellow (soft lavender)
        color3  #BC4A7C
        color11 #BC4A7C

        # Blue (blend of purple)
        color4  #270925
        color12 #270925

        # Magenta
        color5  #BC4A7C
        color13 #BC4A7C

        # Cyan (blend of redwood and fuchsia)
        color6  #A64449
        color14 #A64449

        # White (very light lavender for readability)
        color7  #F7ECFC
        color15 #F7ECFC
      '';
    };
  };
} # ⟦ΔΒ⟧
