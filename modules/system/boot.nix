{ ... }:
{
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;  # Keep last 10 generations
    editor = false;  # Security
  };
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Faster boot
  boot.loader.timeout = 1;
  boot.kernelParams = [ "quiet" ];
}# ⟦ΔΒ⟧
