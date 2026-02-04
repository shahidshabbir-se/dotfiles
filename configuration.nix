# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.erosanix.nixosModules.protonvpn
    ];

  services.protonvpn = {
    enable = true;
    autostart = false; # Set to false so you can debug without losing internet on boot
    interface = {
      privateKeyFile = "/var/lib/protonvpn/private.key";
      dns = {
        enable = true;
        ip = "1.1.1.1"; # Explicitly use Cloudflare DNS to avoid resolution issues
      };
    };
    endpoint = {
      publicKey = "xGIfeXZPiiMUX1lCAXA7VLX12RefzAZEevm6/Yd1yW4=";
      ip = "185.107.56.143";
    };
  };

  # Ensure you have a fallback DNS if the VPN fails
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  nixpkgs.config.allowUnfree = true;
  # configuration.nix
  programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  # ];
  services.xserver.videoDrivers = [ "amdgpu" ];


  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;


  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Use GRUB for dual-boot with Windows
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev"; # For EFI systems
    efiSupport = true;
    useOSProber = true; # Detect Windows automatically
    theme = pkgs.catppuccin-grub;
    gfxmodeEfi = "1920x1080"; # Adjust to your screen resolution
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  services.tumbler.enable = true;
  services.gvfs.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true;
  time.timeZone = "Asia/Karachi";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.libinput.enable = true;
  services.libinput.touchpad.accelSpeed = "1.0";
  services.upower.enable = true;

  users.users.shahid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "kvm" ];
    packages = with pkgs; [
      hyprland
      starship
      git
      openssh
      home-manager
    ];
    shell = pkgs.zsh;
  };
  home-manager.backupFileExtension = "bak";

  environment.systemPackages = with pkgs; [
    openvpn
    swww
    (sddm-astronaut.override {
      themeConfig = {
        ScreenWidth = "1920";
        ScreenHeight = "1080";
        Font = "SF Pro Display";
        FontSize = "12";
        RoundCorners = "20";

        # Video background
        Background = "${./assets/login-background.mp4}";
        BackgroundSpeed = "1.0";
        PauseBackground = "false"; # Set to true to pause video
        CropBackground = "true";
        BackgroundHorizontalAlignment = "center";
        BackgroundVerticalAlignment = "center";
        DimBackground = "0.3";

        PartialBlur = "false";
        BlurMax = "35";
        Blur = "2.0";
        HaveFormBackground = "false";
        FormPosition = "center";
      };
    })
  ];

  programs.hyprland.enable = true;
  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.blex-mono
    pkgs.inter
    (pkgs.stdenv.mkDerivation {
      name = "sf-pro-display";
      src = ./config/fonts/sf-pro-display;
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        cp *.OTF $out/share/fonts/opentype
      '';
    })
  ];
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = { };
          otherlayer = { };
        };
        extraConfig = ''
          [ids]
          *

          [main]
          capslock = overload(control, esc)
          esc = capslock
          ctrl+equal = page_up
        '';
      };
    };
  };

  programs.hyprland.xwayland.enable = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than +1";
  };

  nix.settings.auto-optimise-store = true;

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    autoNumlock = true;
    theme = "sddm-astronaut-theme";
    wayland = {
      enable = true;
      compositor = "weston";
    };
    extraPackages = with pkgs; [
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

