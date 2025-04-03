{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  programs.adb.enable = true;
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
  programs.browserpass.enable = true;

  time.timeZone = "Asia/Karachi";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;
  # services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  # services.kanata = {
  #   enable = true;
  #   keyboards = {
  #     internalKeyboard = {
  #       devices = [
  #         "/dev/input/by-path/pci-0000:00:14.0-usb-0:1:1.1-event-kbd"
  #         "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:1:1.1-event-kbd"
  #         "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
  #       ];
  #       extraDefCfg = "process-unmapped-keys yes";
  #       config = ''
  #         (defsrc
  #           esc caps a s d f j k l ;
  #         )
  #         (defvar
  #           tap-time 180
  #           hold-time 230
  #         )
  #
  #         (defalias
  #           esc caps
  #           caps (tap-hold 100 100 esc lctl)
  #           a (multi f24 (tap-hold $tap-time $hold-time a lmet))
  #           s (multi f24 (tap-hold $tap-time $hold-time s lalt))
  #           d (multi f24 (tap-hold $tap-time $hold-time d lsft))
  #           f (multi f24 (tap-hold $tap-time $hold-time f lctl))
  #           j (multi f24 (tap-hold $tap-time $hold-time j rctl))
  #           k (multi f24 (tap-hold $tap-time $hold-time k rsft))
  #           l (multi f24 (tap-hold $tap-time $hold-time l ralt))
  #           ; (multi f24 (tap-hold $tap-time $hold-time ; rmet))
  #         )
  #
  #         (deflayer base
  #           @esc @caps @a @s @d @f @j @k @l @;
  #         )
  #       '';
  #     };
  #   };
  # };



  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  networking.wireguard.enable = true;

  services.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  services.pipewire = {
    enable = false;
    # pulse.enable = true;
  };

  services.libinput.enable = true;
  services.libinput.touchpad.accelSpeed = "1.0";
  services.upower.enable = true;

  users.users.shahid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "kvm" "adbusers" ];
    packages = with pkgs; [
      hyprland
      starship
      zsh
      git
      home-manager
      catppuccin-sddm
    ];
    shell = pkgs.zsh;
  };


  environment.systemPackages = with pkgs; [
    browserpass
    (
      catppuccin-sddm.override {
        flavor = "mocha";
        font = "JetBrainsMono Nerd Font";
        fontSize = "9";
        background = ./wallpapers/main.png;
        loginBackground = true;
      }
    )
  ];

  home-manager.backupFileExtension = "backup";
  programs.hyprland.enable = true;
  virtualisation.docker.enable = true;
  programs.zsh.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
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
    theme = "catppuccin-mocha";
    package = pkgs.kdePackages.sddm;
    autoNumlock = true;
  };
  system.stateVersion = "25.05";
}
