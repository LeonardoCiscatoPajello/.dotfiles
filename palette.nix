{
  # Central Color palette
  colors = rec {
    # UI
    bg         = "#101014";
    bgAlt      = "#181B20";
    overlay    = "#22262C";
    border     = "#2E3239";
    fg         = "#E4DFD9";
    fgAlt      = "#D7D2CC";
    
    # ANSI base
    black      = "#101014";
    blackBright= "#383B44";
    red        = "#A6463E";
    redBright  = "#C85A53";
    green      = "#6E8F49";
    greenBright= "#8CB664";
    yellow     = "#C9A542";
    yellowBright= "#E3C166";
    blue       = "#3F648C";
    blueBright = "#4C7CB0";
    magenta    = "#BC4A7C";
    magentaBright="#D068A0";
    cyan       = "#4E7A7F";
    cyanBright = "#66A2A7";
    white      = "#D7D2CC";
    whiteBright= "#F2ECE6";
    
    # Cursor / selection
    cursor     = "#E3C166";
    selectionBg= "#3F2644";
    selectionFg= "#EDE8E2";
    
    # Accents
    accent     = "#C9A542"; # gold
    accent2    = "#BC4A7C"; # magenta
    
    # Semantic aliases
    ok           = "#6E8F49";
    error        = "#A6463E";
    warn         = "#E3C166";
    info         = "#4E7A7F";

    # Hyprland sematic
    borderActive = accent;
    borderInactive = border;
    borderUrgent = accent2;
  };
} # ⟦ΔΒ⟧
