{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ruby_3_3
    nodejs
    nodePackages.mermaid-cli
    lua-language-server
    stylua
    luarocks
  ];
}# ⟦ΔΒ⟧
