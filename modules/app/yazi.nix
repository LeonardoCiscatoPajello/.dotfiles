{ pkgs, ... }:
let
  palette = import ../esthetics/palette.nix;
  c = palette.colors;
in
{
  programs.yazi = {
    enable = true;
    settings = {
      opener.edit = [
        { run = "nvim \"$@\""; block = true; desc = "Edit"; }
      ];
    };
  };

  # Minimal hex theme (all direct values)
  home.file.".config/yazi/theme.toml".text = ''
    [mgr]
    cwd          = { fg = "${c.accent}", bold = true }
    selection    = { fg = "${c.bg}", bg = "${c.accent}" }
    hovered      = { fg = "${c.accent2}", bg = "${c.bgAlt}" }
    find_keyword = { fg = "${c.accent2}", bold = true }

    [status]
    mode_normal  = { fg = "${c.bg}", bg = "${c.accent}", bold = true }
    mode_select  = { fg = "${c.bg}", bg = "${c.accent2}", bold = true }

    [input]
    border = { fg = "${c.accent}" }

    [filetype]
    dir   = { fg = "${c.accent}", bold = true }
    exec  = { fg = "${c.ok}", bold = true }
    link  = { fg = "${c.info}" }
    image = { fg = "${c.accent2}" }
    video = { fg = "${c.accent3}" }
    archive = { fg = "${c.warn}" }
    temp  = { fg = "${c.error}" }
  '';
} # ⟦ΔΒ⟧
