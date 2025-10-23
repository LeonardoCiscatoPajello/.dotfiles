{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    android-studio 
    flutter 
    arduino-ide 
    arduino-cli
  ];

  services.udev.packages = with pkgs; [ arduino ];
}# ⟦ΔΒ⟧
