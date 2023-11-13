{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    useOSProber = true;
  };

  # Linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable networking
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone and locale
  time.timeZone = "Asia/Colombo";
  i18n.defaultLocale = "en_US.UTF-8";
  time.hardwareClockInLocalTime = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # fwupd is a simple daemon allowing you to update some devices' firmware, including UEFI for several machines.
  services.fwupd.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # services.blueman.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Shell configuration, ZSH
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      # z - jump around
      source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_THEME="lambda"
      plugins=(git)
      source $ZSH/oh-my-zsh.sh
    '';
    promptInit = "";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes and the new command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tlm = {
    isNormalUser = true;
    description = "Thilina Lakshan";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
		shell = pkgs.zsh;
    packages = with pkgs; [
      firefox brave google-chrome
      kate 
      vscode-with-extensions 
      android-studio
      jetbrains.webstorm jetbrains.idea-ultimate
      stremio mpv 
      obs-studio
      libsForQt5.yakuake
    ];
  };

  # Android
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  # Git
  # programs.git = {
  #   enable = true;
  #   userName  = "Thilina Lakshan";
  #   userEmail = "thilina.18@cse.mrt.ac.lk";
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    os-prober
    vim neovim
    wget curl aria2
    gitFull gh
    python312
    lshw pciutils fwupd
  ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "IosevkaTerm" ]; })
  ];

  system.stateVersion = "23.05";

}
