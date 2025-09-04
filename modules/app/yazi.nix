{ config, pkgs, lib, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;

  yaziSmart = pkgs.writeShellScriptBin "yazi-smart" ''
    #!/usr/bin/env bash
    # Try to get focused kitty cwd
    if command -v kitty >/dev/null && command -v jq >/dev/null; then
      json="$(kitty @ ls --match focused 2>/dev/null || true)"
      dir="$(echo "$json" | jq -r '.[0].cwd // empty' 2>/dev/null || true)"
    fi
    [ -d "$dir" ] || dir="$HOME"
    exec kitty --class Yazi -e yazi "$dir"
  '';
in
{
  home.packages = [ yaziSmart pkgs.jq ];

  programs.yazi = {
    enable = true;
    settings = {
      flavor = "my";
      opener.edit = [
        { run = "nvim \"$@\""; block = true; desc = "Edit"; }
      ];
    };
  };

  # Custom flavor definition (palette only)
  home.file.".config/yazi/flavors/my.toml".text = ''
    [flavor]
    name = "my"

    [palette]
    accent   = "${c.accent}"
    accent2  = "${c.accent2}"
    accent3  = "${c.accent3}"
    bg       = "${c.bg}"
    bg_alt   = "${c.bgAlt}"
    fg       = "${c.fg}"
    fg_alt   = "${c.fgAlt}"
    ok       = "${c.ok}"
    warn     = "${c.warn}"
    error    = "${c.error}"
    info     = "${c.info}"
    highlight= "${c.highlight}"
  '';

  # Theme: ONLY style sections (no [palette] here)
  home.file.".config/yazi/theme.toml".text = ''
    [mgr]
    cwd        = { fg = "accent", bold = true }
    hovered    = { fg = "accent2", bg = "bg_alt" }
    selection  = { fg = "bg", bg = "accent" }
    find_keyword = { fg = "accent2", bold = true }

    [status]
    mode_normal = { fg = "bg", bg = "accent", bold = true }
    mode_select = { fg = "bg", bg = "accent2", bold = true }

    [input]
    border = { fg = "accent" }

    [filetype]
    dir  = { fg = "accent", bold = true }
    exec = { fg = "ok", bold = true }
    link = { fg = "info" }
    image = { fg = "accent2" }
    video = { fg = "accent3" }
    archive = { fg = "warn" }
    temp = { fg = "error" }
  '';
} # ⟦ΔΒ⟧
