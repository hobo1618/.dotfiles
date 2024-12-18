# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  keyd = pkgs.callPackage ./keyd { };
  keydConfig = builtins.readFile ./keyd/keymaps.conf;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Opt in to flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services = {
    # https://github.com/NixOS/nixpkgs/issues/59603#issuecomment-1356844284
    NetworkManager-wait-online.enable = false;

    keyd = {
      enable = true;
      description = "Keyd remapping daemon";
      unitConfig = {
        Requires = "local-fs.target";
        After = "local-fs.target";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.keyd}/bin/keyd";
      };
    };
  };


  # systemd.tmpfiles.rules = [
  #   "d /var/lib/docker/volumes/falkordb_data 0755 root docker - -"
  #   "f /var/run/docker.sock 0660 root docker - -"
  # ];

  environment.etc."keyd/default.conf".text = keydConfig;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver = {
    # Even though you're using Wayland, this section applies to keymaps
    xkb.layout = "us"; # or your preferred layout
    xkb.options = "ctrl:nocaps";
  };

  programs = {
    hyprland.enable = true; # enable Hyprland
  };

  environment.shells = with pkgs; [ fish ];
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  hardware.opengl.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.willh = {
    isNormalUser = true;
    description = "Will Hobden";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  virtualisation.docker = {
    enable = true;
    #     daemon.settings = {
    #       data-root = "/var/lib/docker";
    #     };
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.neo4j = {
    enable = true;
    directories = {
      home = "/tmp/neo4j"; # Set your desired home directory
      data = "/home/willh/neo4j/data"; # Set your desired home directory
    };
  };
  # Install firefox.
  programs.firefox = {
    enable = true;
    package = with pkgs; (firefox.override { extraNativeMessagingHosts = [ passff-host ]; });
  };

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    blueman
    deno
    fish
    gcc9
    gh
    ghostscript
    git
    gnomeExtensions.paperwm
    gnome.gnome-tweaks
    gnumake
    go
    google-chrome
    imagemagick
    jq
    keyd
    lf
    neovim
    nerdfonts
    nodePackages.vercel
    nix-prefetch-github
    nushell
    pciutils
    pipewire
    pipx
    poetry
    pyenv
    python3
    python3Packages.setuptools
    python312
    python313
    redis
    sqlite
    unzip
    vim
    wget
    xclip
    zoom-us
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.keyd.enable = true;
  services.blueman.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?

}
