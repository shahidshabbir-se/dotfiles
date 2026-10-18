# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# { pkgs, inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  nautilusMyComputerSrc = pkgs.fetchFromGitHub {
    owner = "yannmasoch";
    repo = "nautilus-my-computer";
    rev = "4c6247e8210239ecc8de66fd7a9c793dc9a7e66f";
    hash = "sha256-+hE39OIp1+uq0TG5E1f4VocK0iMv5xkXLJnmSal5FZM=";
  };

  nautilusMyComputer =
    (pkgs.callPackage "${nautilusMyComputerSrc}/packaging/nix/package.nix" {
      src = nautilusMyComputerSrc;
    }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace nautilus-my-computer.py \
            --replace-fail \
              'sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))' \
              'sys.path.insert(0, "${pkgs.python3Packages.pycairo}/${pkgs.python3.sitePackages}")
          sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))'

          substituteInPlace nautilus_my_computer/main.py \
            --replace-fail \
              '        wrapper.append(native_listbox)' \
              '        if native_listbox.get_parent() is not None:
                      native_listbox.unparent()
                  wrapper.append(native_listbox)'
        '';
      });

  grubTheme = pkgs.catppuccin-grub.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      rm "$out/background.png"
      ${pkgs.gnused}/bin/sed -i \
        '/^desktop-image:/d; /^desktop-image-scale-method:/d' "$out/theme.txt"
    '';
  });

in

{
  programs = {
    qylock = {
      enable = true;
      theme = "sword";
      # Home Manager installs qylock-lock into the user's profile.
      quickshell.enable = false;
    };

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
    zsh.enable = true;
    gamemode.enable = true;

    # Provides Steam's FHS runtime for Proton/umu pressure-vessel.
    # Lutris can then run GE-Proton without the NixOS `bwrap: execvp true`
    # failure caused by missing /usr/bin runtime tools.
    steam.enable = true;
    steam.extraCompatPackages = with pkgs; [ steam-run ];

    hyprland.enable = true;
    hyprland.xwayland.enable = true;
  };

  imports = [
    # Hardware config is imported per-device from flake.nix
    ./modules/power-management.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    # android_sdk.accept_license = true;
  };

  nixpkgs.overlays = [
    (
      final: prev:
      let
        flags = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
        addFlagsToElectron =
          drv:
          if !(drv ? overrideAttrs) then
            drv
          else
            drv.overrideAttrs (
              old:
              (prev.lib.optionalAttrs (old ? buildCommand && old ? passthru && old.passthru ? unwrapped) {
                buildCommand =
                  builtins.replaceStrings
                    [ "makeWrapper \"${old.passthru.unwrapped}/libexec/electron/electron\" \"$out/bin/electron\"" ]
                    [
                      "makeWrapper \"${old.passthru.unwrapped}/libexec/electron/electron\" \"$out/bin/electron\" --add-flags \"${flags}\""
                    ]
                    old.buildCommand;
              })
              // (prev.lib.optionalAttrs (old ? preFixup) {
                preFixup =
                  builtins.replaceStrings
                    [ "makeWrapper \"$out/libexec/electron/electron\" $out/bin/electron" ]
                    [ "makeWrapper \"$out/libexec/electron/electron\" $out/bin/electron --add-flags \"${flags}\"" ]
                    old.preFixup;
              })
            );
      in
      {
        # nixpkgs' default `electron` is electron_43, so wrapping that one
        # attribute is enough to give every electron-based app the HDR flags.
        electron_43 = addFlagsToElectron prev.electron_43;
      }
    )
  ];
  environment = {

    sessionVariables = {
      CHROME_EXTRA_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      CHROMIUM_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      CHROMIUM_USER_FLAGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
      ELECTRON_EXTRA_LAUNCH_ARGS = "--disable-features=WaylandWpColorManagerV1,WaylandColorManagement --force-color-profile=srgb --enable-features=WaylandLinuxDrmSyncobj";
    };

    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
      "/share/nautilus-python"
      "/share/glib-2.0"
    ];

    systemPackages = with pkgs; [
      openvpn
      gamescope
      lutris-unwrapped
      winetricks
      wineWow64Packages.staging
      protonup-qt
      mangohud
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      nautilus-python
      nautilusMyComputer

      # 32-bit Windows runtime libs required by wine/Proton (vulkan, opengl, gnutls, alsa).
      # Without these lutris fails with "libGL.so.1 missing" / "libvulkan.so.1 missing"
      # and pressure-vessel (umu) can't execvp coreutils like `true`.
      pkgsi686Linux.libGL
      pkgsi686Linux.vulkan-loader
      pkgsi686Linux.gnutls
      pkgsi686Linux.alsa-lib
      pkgsi686Linux.freetype
      pkgsi686Linux.glib.out
      pkgsi686Linux.dbus.lib

      # Bubblewrap is invoked by pressure-vessel/umu under GE-Proton.
      bubblewrap
      steam-run
      vulkan-tools
      # android-tools
    ];
  };
  services = {
    xserver = {
      videoDrivers = lib.mkDefault [ "amdgpu" ];

      enable = true;

    };
    openssh.enable = true;
    tailscale = {
      enable = true;
      extraSetFlags = [ "--operator=shahid" ];
    };

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
            # Keep the PipeWire volume across Bluetooth reconnects instead of
            # accepting the headset's often-maxed hardware volume.
            "bluez5.enable-hw-volume" = false;
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
  systemd = {
    services.bluetooth-auto-connect = {

      # BlueZ trusts bonded devices but does not initiate Classic Bluetooth
      # connections after its daemon starts. Retry trusted devices briefly without
      # blocking Bluetooth startup or NixOS activation.

      description = "Reconnect Bluetooth headsets after BlueZ starts";
      wantedBy = [ "bluetooth.service" ];
      after = [ "bluetooth.service" ];
      partOf = [ "bluetooth.service" ];
      path = with pkgs; [
        bluez
        coreutils
        gawk
      ];
      serviceConfig = {
        Type = "exec";
        TimeoutStopSec = "5s";
      };
      script = ''
        bluetoothctl power on || true

        for _ in $(seq 1 6); do
          bluetoothctl devices Trusted |
            awk '$1 == "Device" && $2 ~ /^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$/ { print $2 }' |
            while read -r device; do
              bluetoothctl --timeout 5 connect "$device" || true
            done
          sleep 5
        done
      '';
    };

    user.services.wireplumber-usb-reset = {
      description = "Restart WirePlumber when USB speaker connects";
      after = [ "wireplumber.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wireplumber";
      };
    };

    services.sddm.preStart = lib.mkAfter ''
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
    tmpfiles.rules = [
      "L+ /usr/bin/true    - - - - /run/current-system/sw/bin/true"
      "L+ /usr/bin/false   - - - - /run/current-system/sw/bin/false"
      "L+ /usr/bin/env     - - - - /run/current-system/sw/bin/env"
    ];
  };

  networking = {
    hostName = "nixos";
    firewall.allowedTCPPorts = [ 4096 ];
    networkmanager.enable = true;
    networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  };
  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "logo.nologo"
      "plymouth.use-simpledrm"
      "rd.udev.log_level=3"
      "udev.log_level=3"
      "vt.global_cursor_default=0"
      "rd.systemd.show_status=false"
      "systemd.show_status=false"
    ];
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        theme = grubTheme;
        gfxmodeEfi = "auto";
        gfxpayloadEfi = "keep";
        splashImage = null;
      };

      timeout = 10;

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };

    };
  };

  time.timeZone = "Asia/Karachi";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.shahid = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "audio"
      "kvm"
      "adbusers"
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
  # Avoid collisions with existing user-managed *.bak files during activation.
  home-manager.backupFileExtension = "hm-backup";
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
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.space-mono
    pkgs.noto-fonts
    (pkgs.stdenv.mkDerivation {
      name = "sf-pro-display";
      src = ./config/fonts/sf-pro-display;
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        cp *.OTF $out/share/fonts/opentype
      '';
    })
  ];

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

  # Freedesktop Secret Service backend used by Doppler and other CLI tools.
  # This enables only the keyring daemon, not the GNOME desktop environment.
  services.gnome.gnome-keyring.enable = true;

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
      extraRules = [
        {
          users = [ "shahid" ];
          commands = [
            {
              command = "/run/current-system/sw/bin/tailscale";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
    polkit.enable = true;
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

  # Keep ESP:/EFI/BOOT/BOOTX64.EFI in sync with the GRUB core that NixOS writes
  # to ESP:/EFI/NixOS-boot/grubx64.efi.
  #
  # The firmware may boot the "UEFI OS" fallback entry, which points at
  # \EFI\BOOT\BOOTX64.EFI, while both binaries share the module prefix
  # (,gpt1)/grub. If the fallback core is older than the modules in that
  # directory, GRUB dies with "error: symbol memcpy not found". This hits on
  # every grub major bump (e.g. 2.12 -> 2.14) via `nix flake update`, because
  # install-grub.pl only refreshes the loader-id path.
  system.activationScripts.syncGrubFallbackEfi = lib.mkIf config.boot.loader.grub.enable {
    text = ''
      grub_efi_dir=${config.boot.loader.efi.efiSysMountPoint}/EFI
      if [ -d "$grub_efi_dir" ]; then
        src="$grub_efi_dir/NixOS-boot/grubx64.efi"
        if [ -f "$src" ]; then
          dst="$grub_efi_dir/BOOT/BOOTX64.EFI"
          if ! ${pkgs.diffutils}/bin/cmp -s "$src" "$dst"; then
            echo "syncing GRUB fallback EFI: $src -> $dst"
            ${pkgs.coreutils}/bin/cp -f "$src" "$dst" || echo "warning: failed to update $dst" >&2
          fi
        fi
      fi
    '';
  };

}
