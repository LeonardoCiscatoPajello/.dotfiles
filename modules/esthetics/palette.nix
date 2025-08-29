o
  colors = rec {
    # Core UI neutrals
    bg           = "#101014";
    bgAlt        = "#181B20";
    overlay      = "#22262C";
    border       = "#2E3239";
    fg           = "#E4DFD9";
    fgAlt        = "#D7D2CC";

    # ANSI palette (base set)
    black        = "#101014";
    blackBright  = "#383B44";
    red          = "#A6463E";
    redBright    = "#C85A53";
    green        = "#6E8F49";
    greenBright  = "#8CB664";
    yellow       = "#C9A542";
    yellowBright = "#E3C166";
    blue         = "#3F648C";
    blueBright   = "#4C7CB0";
    magenta      = "#BC4A7C";   # existing magenta
    magentaBright= "#D068A0";
    cyan         = "#4E7A7F";
    cyanBright   = "#66A2A7";
    white        = "#D7D2CC";
    whiteBright  = "#F2ECE6";

    blueIce       = "#5FA9E6";
    blueIceBright = "#8FCCFF";

    # Extended purples & pinks
    purpleDeep    = "#2D1950";  # very dark purple (good for backgrounds / borders)
    purple        = "#53307D";  # main purple
    purpleBright  = "#7B49AE";  # vivid purple highlight

    fuchsia       = "#F15BB5";  # stronger pink than magenta
    fuchsiaBright = "#FF84CA";  # bright pink highlight / flash

    # Cursor / selection
    cursor       = yellowBright;
    selectionBg  = "#3F2644";
    selectionFg  = "#EDE8E2";

    # Accents (existing)
    accent       = yellow;
    accent2      = magenta;

    # New accent slots (non-breaking)
    accent3      = purple;
    accentPink   = fuchsia;

    # Semantic aliases
    ok           = green;
    error        = red;
    warn         = yellowBright;
    info         = cyan;
    infoStrong   = blueBright;    # or blueIceBright if you adopt ice blues

    # Extra semantic (optional future use)
    highlight    = fuchsiaBright;
    focus        = purpleBright;

    # Hyprland border semantics
    borderActive   = accent;
    borderInactive = border;
    borderUrgent   = accent2;
  };
} # ⟦ΔΒ⟧
