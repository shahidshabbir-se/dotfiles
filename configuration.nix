# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, ... }:

{
  imports = [
    # Hardware config is imported per-device from flake.nix
  ];

  nixpkgs.config.allowUnfree = true;
  # configuration.nix
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  # ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  networking.hostName = "nixos";
  networking.firewall.allowedTCPPorts = [ 4096 ];
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
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
      "20-jieli-usb-speaker" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "alsa_card.usb-Jieli_Technology_USB_Composite_Device_425031583436380E-00"; }
            ];
            actions = {
              update-props = {
                "api.alsa.soft-mixer" = true;
                "device.profile" = "output:analog-stereo";
                "priority.session" = 1500; # Lower than BT so BT takes over when connected
              };
            };
          }
        ];
      };
      "30-bluetooth-priority" = {
        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions = {
              update-props = {
                "priority.session" = 2000; # Highest — auto-switches to BT when connected
              };
            };
          }
        ];
      };
    };
  };

  # Restart WirePlumber when USB speaker is plugged in so it initializes on boot
  services.udev.extraRules = ''
    SUBSYSTEM=="sound", ACTION=="add", ATTRS{idVendor}=="3654", ATTRS{idProduct}=="4755", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="wireplumber-usb-reset.service"
  '';

  systemd.user.services.wireplumber-usb-reset = {
    description = "Restart WirePlumber when USB speaker connects";
    after = [ "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };

  services.libinput.enable = true;
  services.libinput.touchpad.accelSpeed = "1.0";
  services.upower.enable = true;

  users.users.shahid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "audio"
      "kvm"
      "input"
      "networkmanager"
    ];
    packages = with pkgs; [
      # hyprland
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
    # swww
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

  # programs.hyprland.enable = true;

  # i3 (X11 session for Upwork compatibility)
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3lock-color
      i3status
      numlockx
      xclip
      xsel
      maim
      xdotool
      xorg.xrandr
      arandr
      autorandr
      picom
      feh
      dunst
      polybar
      haskellPackages.greenclip
    ];
  };
  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.lilex
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.daddy-time-mono
    pkgs.icomoon-feather
    pkgs.inter
    (pkgs.stdenv.mkDerivation {
      name = "sf-pro-display";
      src = ./config/fonts/sf-pro-display;
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        cp *.OTF $out/share/fonts/opentype
      '';
    })
    (pkgs.stdenv.mkDerivation {
      name = "cartograph-cf";
      src = ./config/fonts/cartograph-cf;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp *.ttf $out/share/fonts/truetype
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

  # programs.hyprland.xwayland.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  nix.settings.auto-optimise-store = true;

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    autoNumlock = true;
    theme = "sddm-astronaut-theme";
    # wayland = {
    #   enable = true;
    #   compositor = "weston";
    # };
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
