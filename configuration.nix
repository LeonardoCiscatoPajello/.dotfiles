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

    # Login Manager
    greetd = {
      enable = true;
      vt = 7;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --asterisks \
          --cmd 'uwsm start hyprland'";
          user = "greeter";
        };
      };
    };
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
    lazygit
    tmux
    fprintd
    btop
    neofetch
    curl
    lua
    tree-sitter
    ripgrep
    fd
    nodejs
    gcc
    zip
    unzip
    fzf
    stylua
    zsh
    bc
    wl-clipboard-rs
    hyprlock
    hyprcursor
    rose-pine-hyprcursor
    xournalpp
    greetd.tuigreet
    socat
    mako # Notification Deamnon

    # --- Hyprland section ---
    hyprlock 
    hyprshot
    hyprpaper
    hypridle
    
    # --- C / C++ Toolchain & Build ---
    clang
    clang-tools            # includes clangd, clang-tidy, etc
    cmake
    gnumake
    pkg-config
    bear                   # generate compile_commands.json
    lldb
    gdb
    ccache                 # optional build cache

    # --- Python Tooling ---
    python3Full            # richer stdlib; remove plain python3 above
    pipx                   # isolated app installs
    black
    ruff
    python313Packages.debugpy                # debugger backend
    python313Packages.pyserial
    pyright
    jdt-language-server

    # --- Java Tooling ---
    jdk21
    maven
    google-java-format
    jetbrains.idea-community 

    # --- General Dev / Editing Helpers ---
    universal-ctags
    shellcheck
    shfmt

    # Added for LaTeX & tooling
    texlive.combined.scheme-medium
    ghostscript
    sioyek
    luarocks

    android-studio
    flutter
  ];

  system.stateVersion = "25.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
} # ⟦ΔΒ⟧
