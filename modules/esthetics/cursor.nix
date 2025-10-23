{ pkgs, ... }:
{
  home.pointerCursor = {
    package = pkgs.rose-pine-hyprcursor;
    name = "rose-pine";
    size = 24;
    hyprcursor.enable = true;
    gtk.enable = true;
    x11.enable = true;
  };
}# ⟦ΔΒ⟧
