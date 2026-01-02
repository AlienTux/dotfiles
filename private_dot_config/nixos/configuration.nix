# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "alientux-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/Guatemala";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "C.UTF-8";
    LC_IDENTIFICATION = "C.UTF-8";
    LC_MEASUREMENT = "C.UTF-8";
    LC_MONETARY = "C.UTF-8";
    LC_NAME = "C.UTF-8";
    LC_NUMERIC = "C.UTF-8";
    LC_PAPER = "C.UTF-8";
    LC_TELEPHONE = "C.UTF-8";
    LC_TIME = "C.UTF-8";
  };

  # Change default configuration location
  # nix.nixPath = [ "nixos-config=/home/alientux/.config/nixos/configuration.nix" ];
  #nix.nixPath = [''
  #                 if nix.channel.enable
  #                   then [
  #                     "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  #                     "nixos-config=/etc/nixos/configuration.nix"
  #                     "/nix/var/nix/profiles/per-user/root/channels"
  #                   ]
  #                 else [];
  #               ''
  #              ];

  ################################################################################
  # Desktop environment and window manager configurations
  ################################################################################

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];

  # Enable Niri
  programs.niri.enable = true;
  programs.niri.useNautilus = false; # Testing out
  security.polkit.enable = true; # polkit
  services.gnome.gnome-keyring.enable = true; # secret service
  security.pam.services.swaylock = {};

  # Polkit
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  
  # Enable Waybar
  programs.waybar.enable = true; # top bar

  # Extend the systemd service environment to be able to execute programs
  systemd.user.services.waybar.path = with pkgs; [
    wlogout
    wleave
    pavucontrol
    waylogout
    pamixer
    procps # Has `pkill`
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alientux = {
    isNormalUser = true;
    description = "AlienTux";
    extraGroups = [ "networkmanager" "wheel" "dialout" "input"];
    shell = pkgs.fish;
    packages = with pkgs; [
    #  here I can install packages for my user. I prefer to do it system-wide
    ];
  };

  ################################################################################
  # Environment variables and portal configs
  ################################################################################

  # Environment variables (Session)
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";

    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
  };

  # Fix mimetypes in Dolphin File Manager when using other window manaders
  # Reference: https://github.com/NixOS/nixpkgs/issues/409986#issuecomment-3217982330
  # Reference: https://discourse.nixos.org/t/hyprland-dolphin-file-manager-trying-to-open-an-image-asks-for-a-program-to-use-for-open-it/69824/3
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  # Desktop portal configuration for screen sharing
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [
          "gtk"
          "gnome"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
  };

  ################################################################################
  # Installing some programs with options
  ################################################################################

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # Install fish
  programs.fish.enable = true;

  # Install firefox
  programs.firefox.enable = true;

  # Install obs-studio
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = [
      pkgs.obs-studio-plugins.obs-vaapi
      pkgs.obs-studio-plugins.droidcam-obs
      pkgs.obs-studio-plugins.obs-vkcapture
      #pkgs.obs-studio-plugins.obs-gstreamer
    ];
  };

  # Install git
  programs.git.enable = true;
  programs.lazygit.enable = true;

  # Configure to be able to run AppImages
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  ################################################################################
  # Package list
  ################################################################################

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    # Applications for Niri
    alacritty fuzzel swaylock mako swayidle xwayland-satellite kitty brightnessctl swaybg
    font-manager
    mangohud
    protonup-ng
    nautilus
    libreoffice
    bibata-cursors
    asusctl
    networkmanagerapplet
    input-remapper
    polkit_gnome
    wlogout
    waylogout
    wleave
    power-profiles-daemon
    #gnome-tweaks
    papirus-icon-theme
    chezmoi
    gedit
    dconf-editor
    # Dolphin File Manager required files
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.baloo-widgets
    kdePackages.baloo
    kdePackages.qtsvg
    kdePackages.kservice # Needed for kbuildsycoca6 to fix mimetypes not showing in Dolphin
    # kdePackages.kio # needed since 25.11
    # kdePackages.kio-fuse #to mount remote filesystems via FUSE
    # kdePackages.kio-extras #extra protocols support (sftp, fish and more)
    # Stuff for Uni...?
    zoom-us
    remmina
    onedrivegui
    eza
    hledger
    nnn
    atuin
    pavucontrol
    pamixer
    vlc
    veloren
    #stremio
    fastfetch
    speedcrunch
    image-roll
    masterpdfeditor
    papers
    feh
    loupe
    gnome-power-manager
    gparted
    librewolf
    floorp-bin
    teamviewer
  ];

  ################################################################################
  # Fonts and icons
  ################################################################################

  # Font and icon configuration
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
    nerd-fonts.symbols-only
    line-awesome
    font-awesome
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  ################################################################################
  # Additional services
  ################################################################################

  services.kanata = {
    enable = true;
    keyboards = {
      gallium.configFile = /home/alientux/bin/kanata/kanata-current/gallium.kbd;
      gallium.port = 5829;
    };
  };

  services.power-profiles-daemon.enable = true;

  # Enable asusd daemon for ROG Control Center
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  services.flatpak.enable = true;

  services.syncthing.enable = true;

  # Enable Upower for Gnome Power Statistics
  services.upower.enable = true;

  # OneDrive
  services.onedrive.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
