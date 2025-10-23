{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    python3Full 
    pipx 
    black 
    ruff 
    python313Packages.debugpy 
    python313Packages.pyserial 
    pyright
  ];
}# ⟦ΔΒ⟧
