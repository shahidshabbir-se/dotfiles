# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# { pkgs, inputs, ... }:
{
  lib,
  pkgs,
  device,
  ...
}:

let
  # adi1090x-lone = pkgs.stdenv.mkDerivation {
  #   name = "adi1090x-lone";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "adi1090x";
  #     repo = "plymouth-themes";
  #     rev = "5d8817458d764bff4ff9daae94cf1bbaabf16ede";
  #     hash = "sha256-e3lRgIBzDkKcWEp5yyRCzQJM6yyTjYC5XmNUZZroDuw=";
  #   };
  #   installPhase = ''
  #     mkdir -p $out/share/plymouth/themes/lone
  #     cp -r $src/pack_3/lone/* $out/share/plymouth/themes/lone/
  #   '';
  # };

  # Qylock "sword" SDDM theme — sparse fetch (~42 MiB), not the full ~1 GiB repo.
  qylockSwordSrc = pkgs.fetchFromGitHub {
    owner = "Darkkal44";
    repo = "qylock";
    rev = "db61a972b4b23728d9944a906e70029ca8a5899d";
    hash = "sha256-pkodIJQPKaaFwsj/TbFuWIDm8RbvQPmB9tsS3fFMZCA=";
    sparseCheckout = [ "themes/sword" ];
  };

  sddmQylockSword = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-qylock-sword";
    version = qylockSwordSrc.rev;
    src = qylockSwordSrc;
    dontBuild = true;
    nativeBuildInputs = [ pkgs.gnused ];
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sword
      cp -r $src/themes/sword/. $out/share/sddm/themes/sword/

      # Default to Hyprland in the greeter UI (GNOME is first alphabetically).
      substituteInPlace $out/share/sddm/themes/sword/Main.qml \
        --replace 'Component.onCompleted: { fadeAnim.start(); keyboard.numLock = true }' \
        'Component.onCompleted: {\
            fadeAnim.start();\
            keyboard.numLock = true;\
            if (typeof sessionModel !== "undefined") {\
                for (var i = 0; i < sessionModel.rowCount(); i++) {\
                    var label = sessionModel.data(sessionModel.index(i, 0), 0x101).toString().toLowerCase();\
                    if (label.indexOf("hyprland") !== -1 && label.indexOf("uwsm") === -1) {\
                        root.sessionIndex = i;\
                        break;\
                    }\
                }\
            }\
        }'
    '';
  };

  bananaCursor = import ./modules/banana-cursor.nix { inherit pkgs; };

in

{
  imports = [
    # Hardware config is imported per-device from flake.nix
    ./modules/power-management.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];
  programs = {
    # configuration.nix
    localsend = {
      enable = true;
      openFirewall = true;
      package = pkgs.localsend.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace lib/config/theme.dart \
            --replace-fail "    fontFamily = null;" "    fontFamily = checkPlatform([TargetPlatform.linux]) ? 'SF Pro Display' : null;"
        '';
      });
    };

    dconf.enable = true;
    nix-ld.enable = true;
    thunar.enable = true;
    thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
    xfconf.enable = true;
    zsh.enable = true;
    gamemode.enable = true;

    # Provides Steam's FHS runtime for Proton/umu pressure-vessel.
    # Lutris can then run GE-Proton without the NixOS `bwrap: execvp true`
    # failure caused by missing /usr/bin runtime tools.
    steam.enable = true;
    steam.extraCompatPackages = with pkgs; [ steam-run ];
  };
  services = {
    xserver = {
      # programs.nix-ld.libraries = with pkgs; [
      # ];
      videoDrivers = lib.mkDefault [ "amdgpu" ];

      enable = true;

      # i3 (X11 session) — disabled in favor of GNOME
      # windowManager.i3 = {
      #   enable = true;
      #   extraPackages = with pkgs; [
      #     i3lock-color
      #     i3status
      #     numlockx
      #     xclip
      #     xsel
      #     maim
      #     xdotool
      #     xorg.xrandr
      #     arandr
      #     autorandr
      #     picom
      #     feh
      #     dunst
      #     polybar
      #     haskellPackages.greenclip
      #   ];
      # };
    };
    # GNOME desktop environment
    desktopManager.gnome.enable = true;

    openssh.enable = true;
    tailscale.enable = true;

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

    tumbler.enable = true;
    gvfs.enable = true;
    gnome.gnome-online-accounts.enable = true;
    blueman.enable = true;
    power-profiles-daemon.enable = true;
    pulseaudio.enable = false;

    pipewire = {
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
    udev.extraRules = ''
      SUBSYSTEM=="sound", ACTION=="add", ATTRS{idVendor}=="3654", ATTRS{idProduct}=="4755", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="wireplumber-usb-reset.service"
    '';

    libinput.enable = true;
    libinput.touchpad.accelSpeed = "1.0";
    upower.enable = true;
    keyd = {
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

    displayManager = {
      defaultSession = "hyprland";

      generic.environment = {
        XCURSOR_THEME = "Banana";
        XCURSOR_SIZE = "48";
      };

      sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm;
        autoNumlock = true;
        # X11 greeter: setupScript/xrdb actually run (Wayland SDDM ignores them).
        wayland.enable = false;
        theme = "sword";
        setupScript = ''
          ${pkgs.xrdb}/bin/xrdb -merge - <<EOF
          Xcursor.theme: Banana
          Xcursor.size: 48
          EOF
          ${pkgs.xset}/bin/xsetroot -cursor_name left_ptr
        '';
        settings = {
          General = {
            DefaultSession = "hyprland.desktop";
            RememberLastSession = false;
            GreeterEnvironment = "XCURSOR_THEME=Banana,XCURSOR_SIZE=48";
          };
          Theme = {
            CursorTheme = "Banana";
            CursorSize = 48;
          };
        };
        extraPackages = [
          sddmQylockSword
          bananaCursor
          pkgs.qt6.qt5compat
          pkgs.qt6.qtmultimedia
          pkgs.qt6.qtsvg
          pkgs.gst_all_1.gst-plugins-base
          pkgs.gst_all_1.gst-plugins-good
          pkgs.gst_all_1.gst-plugins-bad
          pkgs.gst_all_1.gst-plugins-ugly
        ];
      };
    };
  };
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };
  networking = {
    hostName = "nixos";
    firewall.allowedTCPPorts = [ 4096 ];
    networkmanager.enable = true;
    networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  };
  boot = {
    loader = {
      # Use GRUB for dual-boot with Windows
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev"; # For EFI systems
        efiSupport = true;
        useOSProber = true; # Detect Windows automatically
        theme = pkgs.catppuccin-grub.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.imagemagick ];
          installPhase = old.installPhase + ''
            ${pkgs.imagemagick}/bin/magick ${./assets/grub.jpg} $out/background.png
          '';
          # cp ${./assets/logo.png} $out/logo.png
          # ${pkgs.imagemagick}/bin/magick ${./assets/profile.png} $out/logo.png
        });
        gfxmodeEfi = "3440x1440"; # Adjust to your screen resolution
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };
  time.timeZone = "Asia/Karachi";

  i18n.defaultLocale = "en_US.UTF-8";

  systemd.user.services.wireplumber-usb-reset = {
    description = "Restart WirePlumber when USB speaker connects";
    after = [ "wireplumber.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
    };
  };

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
      git
      openssh
      home-manager
    ];
    shell = pkgs.zsh;
  };
  home-manager.backupFileExtension = "bak";

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  environment.systemPackages = with pkgs; [
    openvpn
    gamescope
    lutris-unwrapped
    winetricks
    wineWow64Packages.staging
    protonup-qt
    mangohud
    sddmQylockSword
    bananaCursor

    # 32-bit Windows runtime libs required by wine/Proton (vulkan, opengl, gnutls, alsa).
    # Without these lutris fails with "libGL.so.1 missing" / "libvulkan.so.1 missing"
    # and pressure-vessel (umu) can't execvp coreutils like `true`.
    pkgsi686Linux.libGL
    pkgsi686Linux.vulkan-loader
    pkgsi686Linux.gnutls
    pkgsi686Linux.alsa-lib
    pkgsi686Linux.freetype
    pkgsi686Linux.glib
    pkgsi686Linux.dbus

    # Bubblewrap is invoked by pressure-vessel/umu under GE-Proton.
    bubblewrap
    steam-run
    vulkan-tools
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;
  fonts = {
    fontconfig = {
      enable = true;

      defaultFonts = {
        sansSerif = [ "SF Pro Display" ];
        serif = [ "SF Pro Display" ];
        monospace = [ "SF Mono" ];
      };
    };
  };
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.geist-mono
    pkgs.noto-fonts
    pkgs.rubik
    pkgs.icomoon-feather
    pkgs.inter
    (pkgs.stdenvNoCC.mkDerivation {
      name = "outfit";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/google/fonts/5174b3333331c966c38f4355d50b03ca1c1df2f9/ofl/outfit/Outfit%5Bwght%5D.ttf";
        hash = "sha256-/HKHJz5mkpd24rpU8UT+aZCAvsKfYb9knXDYcUaK6t4=";
      };
      dontUnpack = true;
      installPhase = ''
        install -m 444 -Dt $out/share/fonts/truetype $src
      '';
    })
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

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  systemd.services.sddm.preStart = lib.mkAfter ''
        install -d -m 755 /var/lib/sddm
        STATE=/var/lib/sddm/state.conf
        if [ -f "$STATE" ]; then
          ${pkgs.gnused}/bin/sed -i 's|^Session=.*|Session=hyprland.desktop|' "$STATE"
        else
          cat > "$STATE" <<EOF
    [Last]
    Session=hyprland.desktop
    EOF
        fi
  '';

  xdg.portal = {
    enable = true;
    # Keep xdg-open on the normal MIME-handler path. Upwork's Electron login
    # opens the browser through xdg-open, and the portal OpenURI path is flaky
    # under Hyprland on this setup.
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
    ];
    config.common.default = [
      "gtk"
      "hyprland"
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    rtkit.enable = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

  nix = {
    settings.warn-dirty = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-substituters = [ "https://vicinae.cachix.org" ];
      extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
    };
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
  # Ensure FHS symlinks exist for bwrap/pressure-vessel (umu/Proton)
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/true    - - - - /run/current-system/sw/bin/true"
    "L+ /usr/bin/false   - - - - /run/current-system/sw/bin/false"
    "L+ /usr/bin/env     - - - - /run/current-system/sw/bin/env"
  ];

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
