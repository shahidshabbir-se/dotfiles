{
  config,
  device,
  lib,
  pkgs,
  ...
}:

let
  power = device.power;
  isLaptop = device.type == "laptop";
  homeDirectory = config.home.homeDirectory;

  lockScreen = pkgs.writeShellScript "lock-screen" ''
    set -eu
    locker=${lib.escapeShellArg "${homeDirectory}/.config/lock-screen/lock.sh"}

    if [ ! -r "$locker" ]; then
      ${pkgs.libnotify}/bin/notify-send --urgency=critical \
        "Unable to lock" "Missing $locker; automatic sleep has been cancelled"
      exit 1
    fi

    exec ${pkgs.bash}/bin/bash "$locker"
  '';

  idleAction = pkgs.writeShellScript "hypridle-power-action" ''
    set -eu

    expected_source="''${1:-any}"
    action="''${2:-}"
    on_ac_power=false

    for supply in /sys/class/power_supply/*; do
      [ -r "$supply/type" ] || continue
      type="$(${pkgs.coreutils}/bin/cat "$supply/type")"
      case "$type" in
        Mains|USB|USB_C|USB_PD)
          if [ -r "$supply/online" ] && [ "$(${pkgs.coreutils}/bin/cat "$supply/online")" = 1 ]; then
            on_ac_power=true
            break
          fi
          ;;
      esac
    done

    case "$expected_source" in
      ac) [ "$on_ac_power" = true ] || exit 0 ;;
      battery) [ "$on_ac_power" = false ] || exit 0 ;;
      any) ;;
      *) echo "Unknown power source: $expected_source" >&2; exit 2 ;;
    esac

    case "$action" in
      lock)
        ${pkgs.systemd}/bin/loginctl lock-session
        ;;
      display-off)
        ${pkgs.systemd}/bin/loginctl lock-session
        ${pkgs.coreutils}/bin/sleep 0.5
        ${pkgs.hyprland}/bin/hyprctl -i 0 dispatch dpms off
        ;;
      sleep)
        ${pkgs.systemd}/bin/systemctl suspend-then-hibernate
        ;;
      *) echo "Unknown idle action: $action" >&2; exit 2 ;;
    esac
  '';

  afterSleep = pkgs.writeShellScript "hypridle-after-sleep" ''
    ${pkgs.hyprland}/bin/hyprctl -i 0 dispatch dpms on || true

    ${lib.optionalString (device.type == "desktop") ''
      for delay in 1 2 3; do
        ${pkgs.coreutils}/bin/sleep "$delay"
        if ${pkgs.hyprland}/bin/hyprctl -i 0 reload >/dev/null 2>&1; then
          break
        fi
      done
    ''}
  '';

  laptopListeners = [
    {
      timeout = power.idle.battery.lockAndDisplayOff;
      on-timeout = "${idleAction} battery display-off";
      on-resume = "${pkgs.hyprland}/bin/hyprctl -i 0 dispatch dpms on";
    }
    {
      timeout = power.idle.ac.lockAndDisplayOff;
      on-timeout = "${idleAction} ac display-off";
      on-resume = "${pkgs.hyprland}/bin/hyprctl -i 0 dispatch dpms on";
    }
    {
      timeout = power.idle.battery.sleep;
      on-timeout = "${idleAction} battery sleep";
    }
    {
      timeout = power.idle.ac.sleep;
      on-timeout = "${idleAction} ac sleep";
    }
  ];

  desktopListeners = [
    {
      timeout = power.idle.lock;
      on-timeout = "${idleAction} any lock";
    }
    {
      timeout = power.idle.displayOff;
      on-timeout = "${idleAction} any display-off";
      on-resume = "${pkgs.hyprland}/bin/hyprctl -i 0 dispatch dpms on";
    }
    {
      timeout = power.idle.sleep;
      on-timeout = "${idleAction} any sleep";
    }
  ];
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "${afterSleep}";
        before_sleep_cmd =
          "${pkgs.systemd}/bin/loginctl lock-session && ${pkgs.coreutils}/bin/sleep 1";
        ignore_dbus_inhibit = false;
        lock_cmd = "${lockScreen}";
      };

      listener = if isLaptop then laptopListeners else desktopListeners;
    };
  };
}
