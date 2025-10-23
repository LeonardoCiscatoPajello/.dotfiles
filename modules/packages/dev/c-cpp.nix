{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang 
    cmake 
    gnumake 
    pkg-config 
    bear 
    lldb 
    gdb 
    ccache
  ];
}# ⟦ΔΒ⟧
