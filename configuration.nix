{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.shells = with pkgs; [ zsh bash ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  
  environment.variables.XCURSOR_THEME = "MyHypr";
  environment.variables.XCURSOR_SIZE = "24";
  environment.etc."icons/default/index.theme".text = ''[Icon Theme]\nInherits=MyHypr\n'';


  networking.hostName = "LCP-NixOs";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Rome";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
  };

  services = {

    # Power profiles
    power-profiles-daemon.enable = true;
    desktopManager.plasma6.enable = lib.mkForce false;
    xserver.enable = false;
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;

  users.users = {
    lcp = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Leonardo Ciscato Pajello";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };
    };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  programs.waybar.enable = lib.mkForce false;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    tmux
    fprintd
    htop
    neofetch
    curl
    lua
    tree-sitter
    ripgrep
    fd
    nodejs
    python3
    gcc
    zip
    unzip
    fzf
    stylua
    zsh
    bc
    wl-clipboard-rs
    hyprlock
    rofi-wayland 
  ];

  system.stateVersion = "25.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
} # ⟦ΔΒ⟧
