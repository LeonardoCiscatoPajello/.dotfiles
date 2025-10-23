{ pkgs, ... }:
{
  home.packages = [
    (pkgs.python313.withPackages (ps: with ps; [
      pip 
      pyserial
      paho-mqtt
      mysql-connector
    ]))
  ];
}# ⟦ΔΒ⟧
