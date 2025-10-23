{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # === SYSTEM MODULES ===
    ./modules/system/boot.nix
    ./modules/system/nix.nix
    ./modules/system/networking.nix
    ./modules/system/locale.nix
    ./modules/system/audio.nix
    ./modules/system/display.nix
    ./modules/system/users.nix
    ./modules/system/power.nix

    # === PACKAGES MODULES ===
    ./modules/packages/core.nix
    ./modules/packages/media.nix

    # === DEV MODULES ===
    ./modules/packages/dev/c-cpp.nix
    ./modules/packages/dev/python.nix
    ./modules/packages/dev/java.nix
    ./modules/packages/dev/embedded.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.05";
} # ⟦ΔΒ⟧
