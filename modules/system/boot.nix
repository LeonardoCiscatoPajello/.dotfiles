{ ... }:
{
  # Use GRUB2 as bootloader instead of systemd-boot
  boot.loader.grub = {
    enable = true;
    device = "nodev";  # Don't install to MBR (we're using EFI)
    efiSupport = true;
    efiInstallAsRemovable = false;
    useOSProber = true;  # Detect other OSes (Fedora)
    configurationLimit = 10;  # Keep last 10 generations (same as before)
    
    # Optional: Customize GRUB appearance
    # theme = null;  # Use default theme
    # splashImage = null;
  };
  
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Faster boot
  boot.loader.timeout = 5;
  boot.kernelParams = [ "quiet" ];
}# ⟦ΔΒ⟧
