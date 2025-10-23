{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jdk21 
    maven 
    google-java-format 
    jetbrains.idea-community 
    jdt-language-server
  ];
}# ⟦ΔΒ⟧
