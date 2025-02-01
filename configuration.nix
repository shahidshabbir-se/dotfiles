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

  time.timeZone = "Asia/Karachi";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

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
  services.upower.enable = true;

  users.users.shahid = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "kvm" "adbusers" ];
    packages = with pkgs; [
      hyprland
      zsh
      git
      home-manager
      catppuccin-sddm
    ];
    shell = pkgs.zsh;
  };


  environment.systemPackages = with pkgs; [
    (
      catppuccin-sddm.override {
        flavor = "mocha";
        font = "JetBrainsMono Nerd Font";
        fontSize = "9";
        background = ./wallpapers/lockscreen.jpg;
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
