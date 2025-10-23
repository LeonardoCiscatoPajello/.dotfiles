{ pkgs, ... }:
{
  environment.shells = with pkgs; [ zsh bash ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users.lcp = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Leonardo Ciscato Pajello";
    extraGroups = [ "networkmanager" "wheel" "dialout" "uucp" "plugdev" ];
    packages = with pkgs; [ kdePackages.kate ];
  };
}# ⟦ΔΒ⟧
