{ pkgs, ... }:
{
  programs.neovim = {
    enable = true; 
    extraPython3Packages = ps: [ ps.pynvim ];
  };
}# ⟦ΔΒ⟧
