{ pkgs, ... }:
{
  home.packages = with pkgs; [
    firefox
    discord
    pavucontrol
    brightnessctl
    grim
    slurp
    wl-clipboard
    libnotify
    hello
    
    # Dev addons (temporary home in GUI)
    ruby_3_3
    (python313.withPackages (ps: with ps; [
      pip 
      pyserial
      paho-mqtt
      mysql-connector
    ]))
    nodePackages.mermaid-cli
    sqlite
    clang-tools
    lua-language-server
    stylua
  ];
}# ⟦ΔΒ⟧
