{ pkgs, ... }:
{
  home.packages = [
    (pkgs.python313.withPackages (ps: with ps; [
      pip 
      paho-mqtt
      mysql-connector
      pymata-express
    ]))
  ];
}# ⟦ΔΒ⟧
