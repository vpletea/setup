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
  boot.loader.timeout = 2;
  boot.plymouth.enable = true;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = ["quiet"];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  # Install nerdfonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [pkgs.xterm];
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
    
  # Setting favorite apps in gnome
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      [org.gnome.shell]
      favorite-apps=['firefox.desktop', 'code.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']
    '';
  };  
  

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
 
  # Configure printing
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };

  # Enable pcscd service for yubikey
  services.pcscd.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Docker setup
  virtualisation.docker.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.valentin = {
    isNormalUser = true;
    description = "Valentin";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  nixpkgs.config.allowUnfree = true;

  # nixpkgs.config.packageOverrides = pkgs: {
  #   intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ansible
    bottles
    docker
    firefox
    git
    gnome.gnome-terminal
    gnomeExtensions.dash-to-dock
    gnomeExtensions.power-profile-switcher
    google-chrome
    htop
    k3d
    kubectl
    kubectx
    kubernetes-helm
    plymouth
    terraform
    vim
    vlc
    vscode
    wget
    wine
    yubioath-flutter
  ];

  environment.gnome.excludePackages = with pkgs; [
      gnome-console
      gnome-photos
      gnome-text-editor
      gnome-tour
      gnome.atomix
      gnome.cheese
      gnome.epiphany
      gnome.evince
      gnome.geary
      gnome.gedit
      gnome.gnome-calendar
      gnome.gnome-characters
      gnome.gnome-clocks
      gnome.gnome-contacts
      gnome.gnome-maps
      gnome.gnome-music
      gnome.hitori
      gnome.iagno
      gnome.seahorse
      gnome.simple-scan
      gnome.tali
      gnome.totem
      gnome.yelp
      snapshot
   ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  ## ZSH Setup
  programs.zsh = {
  enable = true;
  autosuggestions.enable = true;
  autosuggestions.extraConfig = {
  "ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" = "20";
  "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE" = "fg=60";
  };
  # Set zsh prompt for zsh autocomplete with up arrow
  promptInit = ''
  autoload -Uz history-search-end
  zle -N history-beginning-search-backward-end history-search-end
  zle -N history-beginning-search-forward-end history-search-end
  bindkey "$terminfo[kcuu1]" history-beginning-search-backward-end
  bindkey "$terminfo[kcud1]" history-beginning-search-forward-end
  ssh-add -q ~/.ssh/github.key
  '';
  loginShellInit = "
  #Set favorite apps in dock and enable extensions
  dconf reset /org/gnome/shell/favorite-apps
  gnome-extensions enable dash-to-dock@micxgx.gmail.com
  gnome-extensions enable power-profile-switcher@eliapasquali.github.io
  ";
  syntaxHighlighting.enable = true;
  histFile = "$HOME/.histfile";
  histSize = 10000;
  enableBashCompletion = true;
  shellAliases = {
    ll = "ls -alh";
    ls = "ls --color=auto --group-directories-first";
    grep = "grep -n --color";
    kc = "k3d cluster create -p 80:80@loadbalancer -p 443:443@loadbalancer";
    kd = "k3d cluster delete";
    nr = "sudo nixos-rebuild switch";
    ne = "sudo nano /etc/nixos/configuration.nix";
    };
  };
  # programs.zsh.completionInit = ["emacs"];
  environment.pathsToLink = [ "/share/zsh" ];
  
  ## Starship prompt setup
  programs.starship = {
  enable = true;
  settings = {
     kubernetes = {
     disabled = false;
     };
   };
  };

  ## SSH setup
  programs.ssh = {
  startAgent = true;
  extraConfig = ''
    StrictHostKeyChecking no
    CanonicalizeHostname yes
    CanonicalDomains h-net.xyz
    Host *
      User devops
      IdentityFile ~/.ssh/homelab.key
    Host gitub
      HostName github.com
      User vpletea
      IdentityFile ~/.ssh/github.key
  '';
  };

  ## FZF Setup
  programs.fzf = {
    fuzzyCompletion = true;
  };

  # Set default shell to zsh
  users.defaultUserShell = pkgs.zsh;

  # List services that you want to enable:
  

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 14d";
  };

  system = {
    autoUpgrade = {
      enable = true;
      dates = "monthly";
    };
  };

  # Power settings
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
  battery = {
     governor = "powersave";
     turbo = "never";
     };
  charger = {
     governor = "performance";
     turbo = "auto";
     };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
