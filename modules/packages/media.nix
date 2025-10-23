{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-medium 
    ghostscript 
    sioyek
  ];
}# ⟦ΔΒ⟧
