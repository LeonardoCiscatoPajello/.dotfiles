{ pkgs, ... }:
{
  home.packages = with pkgs; [
    clang-tools
    lua-language-server
    # pyright already in system python.nix
  ];
}# ⟦ΔΒ⟧
