{
  device,
  lib,
  pkgs,
  ...
}:

let
  power = device.power;
  isLaptop = device.type == "laptop";

  applyPowerProfile = pkgs.writeShellScript "apply-power-profile" ''
    set -eu

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

    desired=${lib.escapeShellArg power.acProfile}
    ${lib.optionalString isLaptop ''
      if [ "$on_ac_power" = false ]; then
        desired=${lib.escapeShellArg power.batteryProfile}
      fi
    ''}

    if ! ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$desired"; then
      if [ "$desired" = performance ]; then
        echo "Performance profile unavailable; falling back to Balanced" >&2
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      else
        exit 1
      fi
    fi
  '';

  applyChargeThreshold = pkgs.writeShellScript "apply-battery-charge-threshold" ''
    set -eu
    found=false

    for threshold in /sys/class/power_supply/BAT*/charge_control_end_threshold; do
      [ -e "$threshold" ] || continue
      found=true
      printf '%s\n' ${toString (power.chargeEndThreshold or 100)} > "$threshold"
    done

    if [ "$found" = false ]; then
      echo "No supported laptop battery charge threshold was found; leaving charging unchanged" >&2
    fi
  '';

  resumePowerPolicy = pkgs.writeShellScript "resume-power-policy" ''
    if [ "''${1:-}" = post ]; then
      ${lib.optionalString isLaptop "${applyChargeThreshold} || true"}
      ${pkgs.systemd}/bin/systemctl --no-block restart power-profile-auto.service || true
    fi
  '';
in
{
  boot.resumeDevice = power.resumeDevice;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowSuspendThenHibernate = true;
    HibernateDelaySec = power.hibernateDelay;
    MemorySleepMode = "deep s2idle";
  };

  services.logind.settings.Login = {
    HandlePowerKey = if isLaptop then "suspend-then-hibernate" else "poweroff";
    HandleLidSwitch = if isLaptop then "suspend-then-hibernate" else "ignore";
    HandleLidSwitchExternalPower = if isLaptop then "suspend-then-hibernate" else "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.upower = lib.mkIf isLaptop {
    usePercentageForPolicy = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  systemd.services.power-profile-auto = {
    description = "Apply the device power profile policy";
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = applyPowerProfile;
    };
  };

  systemd.services.battery-charge-threshold = lib.mkIf isLaptop {
    description = "Limit the ThinkPad battery charge level";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = applyChargeThreshold;
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="?*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="power-profile-auto.service"
    ${lib.optionalString isLaptop ''SUBSYSTEM=="power_supply", KERNEL=="BAT*", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery-charge-threshold.service"''}
  '';

  environment.etc."systemd/system-sleep/power-policy" = {
    source = resumePowerPolicy;
    mode = "0755";
  };
}
