{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    clang 
    clang-tools 
    cmake 
    gnumake 
    pkg-config 
    bear 
    lldb 
    gdb 
    ccache
  ];
}# ⟦ΔΒ⟧
