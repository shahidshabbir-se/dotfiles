//! NetworkManager backend for the bar wifi panel.
//! JSON on stdout. Secrets never on argv (stdin / nmcli show-secrets only).

use qrcode::{EcLevel, QrCode, Version};
use serde::Serialize;
use serde_json::json;
use std::collections::HashSet;
use std::env;
use std::io::{self, Read, Write};
use std::path::Path;
use std::process::{Command, Stdio};
use std::thread;
use std::time::{Duration, Instant};

#[derive(Serialize)]
struct Status {
    kind: String,
    label: String,
    signal: i32,
    frequency: String,
    iface: String,
    ip: String,
    gateway: String,
    prefix: String,
    rx_bytes: u64,
    tx_bytes: u64,
    wifi_enabled: bool,
    router_ping_ms: f64,
    internet_ping_ms: f64,
}

#[derive(Serialize)]
struct Network {
    ssid: String,
    signal: i32,
    security: String,
    connected: bool,
    known: bool,
    in_use: bool,
}

fn main() {
    let mut args = env::args().skip(1);
    let cmd = args.next().unwrap_or_else(|| "help".into());
    let rest: Vec<String> = args.collect();

    let result = match cmd.as_str() {
        "status" => status_cmd(),
        "scan" => scan_cmd(&rest),
        "connect" => connect_cmd(&rest),
        "disconnect" => disconnect_cmd(),
        "forget" => forget_cmd(&rest),
        "wifi" => wifi_cmd(&rest),
        "band" => band_cmd(&rest),
        "dns" => dns_cmd(&rest),
        "password" => password_cmd(&rest),
        "qr" => qr_cmd(&rest),
        "speedtest" => speedtest_cmd(&rest),
        "help" | "-h" | "--help" => {
            print_help();
            Ok(())
        }
        other => Err(format!("unknown command: {other}")),
    };

    if let Err(e) = result {
        eprintln!("qs-network: {e}");
        std::process::exit(1);
    }
}

fn print_help() {
    eprintln!(
        "qs-network <command>\n\
         status                 link + counters + ping (JSON)\n\
         scan [auto|no]         nearby wifi (JSON; auto=rescan)\n\
         connect <ssid>         join; password on stdin if needed\n\
         disconnect             drop active wifi\n\
         forget <ssid>          delete saved profile\n\
         wifi [on|off|toggle]   radio power\n\
         band [auto|2.4|5|6]    show or pin wifi band\n\
         dns [dhcp|cloudflare|google]  show or set DNS\n\
         password [iface]       print active wifi password\n\
         qr [--meta] [iface]    WIFI QR matrix (0/1 rows)\n\
         speedtest <down|up>    live mbps samples (one/sec)\n"
    );
}

fn run(bin: &str, args: &[&str]) -> Result<String, String> {
    let out = Command::new(bin)
        .args(args)
        .output()
        .map_err(|e| format!("{bin}: {e}"))?;
    if !out.status.success() {
        let err = String::from_utf8_lossy(&out.stderr);
        return Err(format!("{bin} {} failed: {}", args.join(" "), err.trim()));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

fn run_ok(bin: &str, args: &[&str]) -> Result<(), String> {
    run(bin, args).map(|_| ())
}

fn nmcli(args: &[&str]) -> Result<String, String> {
    let out = Command::new("nmcli")
        .env("LC_ALL", "C")
        .args(args)
        .output()
        .map_err(|e| format!("nmcli: {e}"))?;
    if !out.status.success() {
        let err = String::from_utf8_lossy(&out.stderr);
        return Err(format!("nmcli {} failed: {}", args.join(" "), err.trim()));
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

fn nmcli_allow_fail(args: &[&str]) -> String {
    nmcli(args).unwrap_or_default()
}

fn wifi_enabled() -> bool {
    nmcli(&["-t", "-f", "WIFI", "radio"])
        .map(|s| s.trim().eq_ignore_ascii_case("enabled"))
        .unwrap_or(false)
}

fn default_iface() -> Option<String> {
    let out = run("ip", &["route", "get", "1.1.1.1"]).ok()?;
    let parts: Vec<&str> = out.split_whitespace().collect();
    parts
        .windows(2)
        .find(|w| w[0] == "dev")
        .map(|w| w[1].to_string())
}

fn is_wireless(iface: &str) -> bool {
    Path::new(&format!("/sys/class/net/{iface}/wireless")).is_dir()
}

fn read_sys_u64(path: &str) -> u64 {
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| s.trim().parse().ok())
        .unwrap_or(0)
}

fn wifi_device() -> Option<String> {
    let raw = nmcli_allow_fail(&["-t", "-f", "DEVICE,TYPE,STATE", "device", "status"]);
    for line in raw.lines() {
        let mut p = line.split(':');
        let dev = p.next().unwrap_or("");
        let ty = p.next().unwrap_or("");
        let state = p.next().unwrap_or("");
        if ty == "wifi" && state.starts_with("connected") {
            return Some(dev.to_string());
        }
    }
    None
}

fn wifi_profile(device: &str) -> String {
    let show = nmcli_allow_fail(&[
        "-t",
        "-f",
        "GENERAL.CONNECTION",
        "device",
        "show",
        device,
    ]);
    for line in show.lines() {
        if let Some((k, v)) = line.split_once(':') {
            if k == "GENERAL.CONNECTION" {
                return v.to_string();
            }
        }
    }
    String::new()
}

fn ping_ms(host: &str) -> f64 {
    let out = Command::new("ping")
        .env("LC_ALL", "C")
        .args(["-n", "-c", "1", "-W", "1", host])
        .output();
    let Ok(out) = out else {
        return -1.0;
    };
    let text = String::from_utf8_lossy(&out.stdout);
    for line in text.lines() {
        for key in ["time=", "time<"] {
            if let Some(idx) = line.find(key) {
                let rest = &line[idx + key.len()..];
                let num: String = rest
                    .chars()
                    .take_while(|c| c.is_ascii_digit() || *c == '.')
                    .collect();
                if let Ok(v) = num.parse::<f64>() {
                    return v;
                }
            }
        }
    }
    -1.0
}

fn status_cmd() -> Result<(), String> {
    let iface = default_iface().unwrap_or_default();
    let mut st = Status {
        kind: "disconnected".into(),
        label: String::new(),
        signal: -1,
        frequency: String::new(),
        iface: iface.clone(),
        ip: String::new(),
        gateway: String::new(),
        prefix: String::new(),
        rx_bytes: 0,
        tx_bytes: 0,
        wifi_enabled: wifi_enabled(),
        router_ping_ms: -1.0,
        internet_ping_ms: -1.0,
    };

    if iface.is_empty() {
        println!("{}", serde_json::to_string(&st).unwrap());
        return Ok(());
    }

    st.rx_bytes = read_sys_u64(&format!("/sys/class/net/{iface}/statistics/rx_bytes"));
    st.tx_bytes = read_sys_u64(&format!("/sys/class/net/{iface}/statistics/tx_bytes"));

    if let Ok(raw) = run("ip", &["-j", "route", "get", "1.1.1.1"]) {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(&raw) {
            if let Some(row) = v.as_array().and_then(|a| a.first()) {
                st.gateway = row
                    .get("gateway")
                    .and_then(|x| x.as_str())
                    .unwrap_or("")
                    .to_string();
                st.ip = row
                    .get("prefsrc")
                    .and_then(|x| x.as_str())
                    .unwrap_or("")
                    .to_string();
            }
        }
    }

    if let Ok(raw) = run("ip", &["-j", "addr", "show", &iface]) {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(&raw) {
            if let Some(info) = v.as_array().and_then(|a| a.first()) {
                if let Some(addrs) = info.get("addr_info").and_then(|x| x.as_array()) {
                    for a in addrs {
                        if a.get("family").and_then(|x| x.as_str()) == Some("inet") {
                            if st.ip.is_empty() {
                                st.ip = a
                                    .get("local")
                                    .and_then(|x| x.as_str())
                                    .unwrap_or("")
                                    .to_string();
                            }
                            st.prefix = a
                                .get("prefixlen")
                                .map(|x| x.to_string())
                                .unwrap_or_default();
                            break;
                        }
                    }
                }
            }
        }
    }

    if is_wireless(&iface) {
        st.kind = "wifi".into();
        if let Ok(show) = nmcli(&[
            "-t",
            "-f",
            "GENERAL.STATE,GENERAL.CONNECTION",
            "device",
            "show",
            &iface,
        ]) {
            let mut state = String::new();
            let mut conn = String::new();
            for line in show.lines() {
                if let Some((k, v)) = line.split_once(':') {
                    match k {
                        "GENERAL.STATE" => state = v.to_string(),
                        "GENERAL.CONNECTION" => conn = v.to_string(),
                        _ => {}
                    }
                }
            }
            if !state.starts_with("100") {
                st.kind = "disconnected".into();
            } else {
                st.label = if conn.is_empty() {
                    iface.clone()
                } else {
                    conn
                };
            }
        }

        if let Ok(list) = nmcli(&[
            "-t",
            "-f",
            "IN-USE,SIGNAL,FREQ,SSID",
            "dev",
            "wifi",
            "list",
            "ifname",
            &iface,
            "--rescan",
            "no",
        ]) {
            for line in list.lines() {
                let mut parts = line.splitn(4, ':');
                let in_use = parts.next().unwrap_or("");
                let signal = parts.next().unwrap_or("");
                let freq = parts.next().unwrap_or("");
                let ssid = parts.next().unwrap_or("");
                if in_use == "*" {
                    st.signal = signal.parse().unwrap_or(-1);
                    st.frequency = freq.to_string();
                    if st.label.is_empty() {
                        st.label = ssid.to_string();
                    }
                    break;
                }
            }
        }
    } else {
        st.kind = "ethernet".into();
        st.label = iface.clone();
    }

    if !st.gateway.is_empty() {
        st.router_ping_ms = ping_ms(&st.gateway);
    }
    st.internet_ping_ms = ping_ms("1.1.1.1");

    println!("{}", serde_json::to_string(&st).unwrap());
    Ok(())
}

fn scan_cmd(args: &[String]) -> Result<(), String> {
    let rescan = match args.first().map(|s| s.as_str()).unwrap_or("auto") {
        "no" | "cache" => "no",
        _ => "auto",
    };
    let raw = nmcli(&[
        "-t",
        "-f",
        "IN-USE,SSID,SIGNAL,SECURITY,BSSID",
        "dev",
        "wifi",
        "list",
        "--rescan",
        rescan,
    ])?;

    let known_raw = nmcli_allow_fail(&["-t", "-f", "NAME,TYPE", "connection", "show"]);
    let mut known = HashSet::new();
    for line in known_raw.lines() {
        if let Some((name, ty)) = line.split_once(':') {
            if ty == "wifi" || ty.contains("wireless") {
                known.insert(name.to_string());
            }
        }
    }

    let mut nets: Vec<Network> = Vec::new();
    let mut seen = HashSet::new();

    for line in raw.lines() {
        let mut parts = line.splitn(5, ':');
        let in_use = parts.next().unwrap_or("") == "*";
        let ssid = parts.next().unwrap_or("").to_string();
        let signal: i32 = parts.next().unwrap_or("0").parse().unwrap_or(0);
        let security = parts.next().unwrap_or("").to_string();
        if ssid.is_empty() || !seen.insert(ssid.clone()) {
            continue;
        }
        let is_known = known.contains(&ssid);
        nets.push(Network {
            connected: in_use,
            known: is_known,
            in_use,
            signal,
            security,
            ssid,
        });
    }

    nets.sort_by(|a, b| {
        b.connected
            .cmp(&a.connected)
            .then(b.known.cmp(&a.known))
            .then(b.signal.cmp(&a.signal))
    });

    println!("{}", serde_json::to_string(&nets).unwrap());
    Ok(())
}

fn connect_cmd(args: &[String]) -> Result<(), String> {
    let ssid = args
        .first()
        .ok_or_else(|| "usage: connect <ssid>".to_string())?;

    let mut secret = String::new();
    if !atty_stdin() {
        io::stdin()
            .read_to_string(&mut secret)
            .map_err(|e| e.to_string())?;
        secret = secret.trim_end_matches(['\n', '\r']).to_string();
    }

    let status = if secret.is_empty() {
        Command::new("nmcli")
            .env("LC_ALL", "C")
            .args(["device", "wifi", "connect", ssid])
            .status()
            .map_err(|e| e.to_string())?
    } else {
        let mut child = Command::new("nmcli")
            .env("LC_ALL", "C")
            .args(["device", "wifi", "connect", ssid, "password", &secret])
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;
        secret.clear();
        child.wait().map_err(|e| e.to_string())?
    };

    if !status.success() {
        return Err(format!("failed to connect to {ssid}"));
    }
    println!("{}", json!({"ok": true, "ssid": ssid}));
    Ok(())
}

fn disconnect_cmd() -> Result<(), String> {
    let iface = default_iface().unwrap_or_default();
    if !iface.is_empty() && is_wireless(&iface) {
        run_ok("nmcli", &["device", "disconnect", &iface])?;
    } else {
        let dev = wifi_device().ok_or_else(|| "no active wifi".to_string())?;
        run_ok("nmcli", &["device", "disconnect", &dev])?;
    }
    println!("{}", json!({"ok": true}));
    Ok(())
}

fn forget_cmd(args: &[String]) -> Result<(), String> {
    let ssid = args
        .first()
        .ok_or_else(|| "usage: forget <ssid>".to_string())?;
    run_ok("nmcli", &["connection", "delete", "id", ssid])?;
    println!("{}", json!({"ok": true, "ssid": ssid}));
    Ok(())
}

fn wifi_cmd(args: &[String]) -> Result<(), String> {
    let sub = args.first().map(|s| s.as_str()).unwrap_or("status");
    match sub {
        "on" => run_ok("nmcli", &["radio", "wifi", "on"])?,
        "off" => run_ok("nmcli", &["radio", "wifi", "off"])?,
        "toggle" => {
            if wifi_enabled() {
                run_ok("nmcli", &["radio", "wifi", "off"])?;
            } else {
                run_ok("nmcli", &["radio", "wifi", "on"])?;
            }
        }
        "status" => {
            println!("{}", json!({"wifi_enabled": wifi_enabled()}));
            return Ok(());
        }
        other => return Err(format!("usage: wifi [on|off|toggle|status], got {other}")),
    }
    println!("{}", json!({"wifi_enabled": wifi_enabled()}));
    Ok(())
}

fn band_for_freq(freq: &str) -> Option<&'static str> {
    let digits: String = freq.chars().take_while(|c| c.is_ascii_digit()).collect();
    let mhz: u32 = digits.parse().ok()?;
    if (2400..2500).contains(&mhz) {
        Some("2.4")
    } else if (4900..5925).contains(&mhz) {
        Some("5")
    } else if (5925..7125).contains(&mhz) {
        Some("6")
    } else {
        None
    }
}

fn nm_band_for(band: &str) -> Result<&'static str, String> {
    match band {
        "2.4" => Ok("bg"),
        "5" => Ok("a"),
        "6" => Ok("6GHz"),
        _ => Err(format!("invalid band: {band}")),
    }
}

fn band_from_nm(v: &str) -> &'static str {
    match v.trim() {
        "bg" => "2.4",
        "a" => "5",
        "6GHz" => "6",
        _ => "auto",
    }
}

fn read_link_freq_ssid(device: &str) -> (String, String) {
    let mut ssid = String::new();
    let mut freq = String::new();
    let list = nmcli_allow_fail(&[
        "-t",
        "-f",
        "IN-USE,FREQ,SSID",
        "dev",
        "wifi",
        "list",
        "ifname",
        device,
        "--rescan",
        "no",
    ]);
    for line in list.lines() {
        let mut parts = line.splitn(3, ':');
        let in_use = parts.next().unwrap_or("");
        let f = parts.next().unwrap_or("");
        let s = parts.next().unwrap_or("");
        if in_use == "*" {
            freq = f.to_string();
            ssid = s.to_string();
            break;
        }
    }
    if ssid.is_empty() {
        ssid = wifi_profile(device);
    }
    (ssid, freq)
}

fn available_bands(device: &str, ssid: &str, current: Option<&str>) -> Vec<String> {
    let mut set = HashSet::new();
    if let Some(c) = current {
        set.insert(c.to_string());
    }
    let list = nmcli_allow_fail(&[
        "-t",
        "-f",
        "FREQ,SSID",
        "dev",
        "wifi",
        "list",
        "ifname",
        device,
        "--rescan",
        "no",
    ]);
    for line in list.lines() {
        let mut parts = line.splitn(2, ':');
        let f = parts.next().unwrap_or("");
        let s = parts.next().unwrap_or("");
        if s == ssid {
            if let Some(b) = band_for_freq(f) {
                set.insert(b.to_string());
            }
        }
    }
    let mut v: Vec<String> = set.into_iter().collect();
    v.sort_by(|a, b| {
        let rank = |x: &str| match x {
            "2.4" => 0,
            "5" => 1,
            "6" => 2,
            _ => 9,
        };
        rank(a).cmp(&rank(b))
    });
    v
}

fn band_cmd(args: &[String]) -> Result<(), String> {
    if args.is_empty() {
        let device = wifi_device().unwrap_or_default();
        if device.is_empty() {
            println!("{}", json!({"band":"","available":[],"selected":"auto"}));
            return Ok(());
        }
        let (ssid, freq) = read_link_freq_ssid(&device);
        if ssid.is_empty() {
            println!("{}", json!({"band":"","available":[],"selected":"auto"}));
            return Ok(());
        }
        let band = band_for_freq(&freq).unwrap_or("").to_string();
        let available =
            available_bands(&device, &ssid, if band.is_empty() { None } else { Some(&band) });
        let profile = wifi_profile(&device);
        let selected = if profile.is_empty() {
            "auto".to_string()
        } else {
            let raw = nmcli_allow_fail(&[
                "-e",
                "no",
                "-g",
                "802-11-wireless.band",
                "connection",
                "show",
                &profile,
            ]);
            band_from_nm(raw.trim()).to_string()
        };
        println!(
            "{}",
            json!({
                "band": band,
                "available": available,
                "selected": selected
            })
        );
        return Ok(());
    }

    let target = args[0].as_str();
    if !matches!(target, "auto" | "2.4" | "5" | "6") {
        return Err("usage: band [auto|2.4|5|6]".into());
    }

    let device = wifi_device().ok_or_else(|| "no connected Wi-Fi device".to_string())?;
    let profile = wifi_profile(&device);
    if profile.is_empty() {
        return Err("no active Wi-Fi connection profile".into());
    }

    let (ssid, freq) = read_link_freq_ssid(&device);
    let current = band_for_freq(&freq).map(|s| s.to_string());
    let available = available_bands(&device, &ssid, current.as_deref());

    let desired = if target == "auto" {
        String::new()
    } else {
        if !available.iter().any(|b| b == target) {
            return Err(format!("{target}GHz is not available on this network"));
        }
        nm_band_for(target)?.to_string()
    };

    let previous = nmcli_allow_fail(&[
        "-e",
        "no",
        "-g",
        "802-11-wireless.band",
        "connection",
        "show",
        &profile,
    ])
    .trim()
    .to_string();

    if previous == desired {
        println!("{}", json!({"ok": true, "selected": target}));
        return Ok(());
    }

    run_ok(
        "nmcli",
        &[
            "connection",
            "modify",
            &profile,
            "802-11-wireless.band",
            &desired,
        ],
    )?;

    if run_ok("nmcli", &["connection", "up", &profile]).is_err() {
        let _ = run_ok(
            "nmcli",
            &[
                "connection",
                "modify",
                &profile,
                "802-11-wireless.band",
                &previous,
            ],
        );
        let _ = run_ok("nmcli", &["connection", "up", &profile]);
        return Err(format!("could not connect on {target}; reverted"));
    }

    println!("{}", json!({"ok": true, "selected": target}));
    Ok(())
}

fn active_connection_name() -> Option<String> {
    let iface = default_iface()?;
    let show = nmcli_allow_fail(&[
        "-t",
        "-f",
        "GENERAL.CONNECTION",
        "device",
        "show",
        &iface,
    ]);
    for line in show.lines() {
        if let Some((k, v)) = line.split_once(':') {
            if k == "GENERAL.CONNECTION" && !v.is_empty() && v != "--" {
                return Some(v.to_string());
            }
        }
    }
    None
}

fn dns_cmd(args: &[String]) -> Result<(), String> {
    if args.is_empty() {
        let conn = active_connection_name().unwrap_or_default();
        let mut provider = "dhcp".to_string();
        let mut servers = String::new();
        if !conn.is_empty() {
            let ignore = nmcli_allow_fail(&[
                "-e",
                "no",
                "-g",
                "ipv4.ignore-auto-dns",
                "connection",
                "show",
                &conn,
            ]);
            let dns = nmcli_allow_fail(&["-e", "no", "-g", "ipv4.dns", "connection", "show", &conn]);
            servers = dns.trim().replace(',', " ");
            if ignore.trim() == "yes" && !servers.is_empty() {
                if servers.contains("1.1.1.1") {
                    provider = "cloudflare".into();
                } else if servers.contains("8.8.8.8") {
                    provider = "google".into();
                } else {
                    provider = "custom".into();
                }
            }
        }
        println!(
            "{}",
            json!({
                "provider": provider,
                "servers": servers,
                "options": ["dhcp", "cloudflare", "google"]
            })
        );
        return Ok(());
    }

    let target = args[0].to_lowercase();
    let conn = active_connection_name().ok_or_else(|| "no active connection".to_string())?;

    match target.as_str() {
        "dhcp" => {
            run_ok(
                "nmcli",
                &[
                    "connection",
                    "modify",
                    &conn,
                    "ipv4.ignore-auto-dns",
                    "no",
                    "ipv4.dns",
                    "",
                ],
            )?;
        }
        "cloudflare" => {
            run_ok(
                "nmcli",
                &[
                    "connection",
                    "modify",
                    &conn,
                    "ipv4.ignore-auto-dns",
                    "yes",
                    "ipv4.dns",
                    "1.1.1.1 1.0.0.1",
                ],
            )?;
        }
        "google" => {
            run_ok(
                "nmcli",
                &[
                    "connection",
                    "modify",
                    &conn,
                    "ipv4.ignore-auto-dns",
                    "yes",
                    "ipv4.dns",
                    "8.8.8.8 8.8.4.4",
                ],
            )?;
        }
        other => return Err(format!("unknown dns provider: {other}")),
    }

    let _ = run_ok("nmcli", &["connection", "up", &conn]);
    println!("{}", json!({"ok": true, "provider": target}));
    Ok(())
}

fn wifi_secrets(iface: &str) -> Result<(String, String, String, bool), String> {
    let uuid = nmcli(&["--get-values", "GENERAL.CON-UUID", "device", "show", iface])?
        .lines()
        .next()
        .unwrap_or("")
        .trim()
        .to_string();
    if uuid.is_empty() || uuid == "--" {
        return Err("No active Wi-Fi connection".into());
    }

    let fields = nmcli(&[
        "--show-secrets",
        "--escape",
        "no",
        "--get-values",
        "802-11-wireless.ssid,802-11-wireless-security.key-mgmt,802-11-wireless-security.psk,802-11-wireless.hidden,802-11-wireless-security.wep-key0",
        "connection",
        "show",
        "uuid",
        &uuid,
    ])?;
    let mut lines = fields.lines();
    let ssid = lines.next().unwrap_or("").to_string();
    let key_mgmt = lines.next().unwrap_or("").to_string();
    let mut password = lines.next().unwrap_or("").to_string();
    let hidden = lines.next().unwrap_or("no") == "yes";
    let wep = lines.next().unwrap_or("").to_string();

    if ssid.is_empty() {
        return Err("Could not read the Wi-Fi name".into());
    }
    if key_mgmt.contains("eap") || key_mgmt.contains("ieee8021x") {
        return Err("Enterprise Wi-Fi cannot be shared with a password QR".into());
    }

    let security = if !key_mgmt.is_empty() && key_mgmt != "none" {
        if password.is_empty() {
            return Err("Could not read the Wi-Fi password".into());
        }
        "WPA".to_string()
    } else if !wep.is_empty() {
        password = wep;
        "WEP".to_string()
    } else {
        "nopass".to_string()
    };

    Ok((ssid, security, password, hidden))
}

fn password_cmd(args: &[String]) -> Result<(), String> {
    let iface = args
        .first()
        .cloned()
        .or_else(wifi_device)
        .or_else(|| {
            let d = default_iface()?;
            if is_wireless(&d) {
                Some(d)
            } else {
                None
            }
        })
        .ok_or_else(|| "No active Wi-Fi connection".to_string())?;

    let (_ssid, security, password, _hidden) = wifi_secrets(&iface)?;
    if security == "nopass" {
        return Err("This network has no password".into());
    }
    println!("{password}");
    Ok(())
}

fn escape_wifi_qr(value: &str) -> String {
    value
        .replace('\\', "\\\\")
        .replace(';', "\\;")
        .replace(',', "\\,")
        .replace(':', "\\:")
}

fn qr_cmd(args: &[String]) -> Result<(), String> {
    let mut emit_meta = false;
    let mut iface = String::new();
    for a in args {
        if a == "--meta" {
            emit_meta = true;
        } else {
            iface = a.clone();
        }
    }
    if iface.is_empty() {
        iface = wifi_device()
            .or_else(|| {
                let d = default_iface()?;
                if is_wireless(&d) {
                    Some(d)
                } else {
                    None
                }
            })
            .ok_or_else(|| "No active Wi-Fi connection".to_string())?;
    }

    let (ssid, security, password, hidden) = wifi_secrets(&iface)?;
    let mut payload = format!(
        "WIFI:T:{};S:{};P:{};",
        security,
        escape_wifi_qr(&ssid),
        escape_wifi_qr(&password)
    );
    if hidden {
        payload.push_str("H:true;");
    }
    payload.push(';');

    if emit_meta {
        println!("meta\t{iface}\t{security}\t{ssid}");
    }

    let code = QrCode::with_version(payload.as_bytes(), Version::Normal(4), EcLevel::M)
        .or_else(|_| QrCode::new(payload.as_bytes()))
        .map_err(|e| format!("qr encode failed: {e}"))?;

    let width = code.width();
    let margin = 4;
    let total = width + margin * 2;
    for y in 0..total {
        let mut row = String::with_capacity(total);
        for x in 0..total {
            let mx = x as i32 - margin as i32;
            let my = y as i32 - margin as i32;
            let dark = mx >= 0
                && my >= 0
                && (mx as usize) < width
                && (my as usize) < width
                && code[(mx as usize, my as usize)] == qrcode::Color::Dark;
            row.push(if dark { '1' } else { '0' });
        }
        println!("{row}");
    }
    Ok(())
}

fn speedtest_cmd(args: &[String]) -> Result<(), String> {
    let direction = args
        .first()
        .map(|s| s.as_str())
        .ok_or_else(|| "usage: speedtest <down|up>".to_string())?;
    if direction != "down" && direction != "up" {
        return Err("usage: speedtest <down|up>".into());
    }

    let iface = default_iface().ok_or_else(|| "No active network interface".to_string())?;
    let rx_path = format!("/sys/class/net/{iface}/statistics/rx_bytes");
    if !Path::new(&rx_path).exists() {
        return Err("No active network interface".into());
    }

    let token = "YXNkZmFzZGxmbnNkYWZoYXNkZmhrYWxm";
    let api = format!(
        "https://api.fast.com/netflix/speedtest/v2?https=true&token={token}&urlCount=3"
    );
    let body = run("curl", &["-fsS", &api])?;
    let v: serde_json::Value =
        serde_json::from_str(&body).map_err(|e| format!("fast.com parse: {e}"))?;
    let urls: Vec<String> = v
        .get("targets")
        .and_then(|t| t.as_array())
        .map(|arr| {
            arr.iter()
                .filter_map(|t| t.get("url").and_then(|u| u.as_str()).map(|s| s.to_string()))
                .collect()
        })
        .unwrap_or_default();
    if urls.is_empty() {
        return Err("Failed to fetch speed test endpoints".into());
    }

    speedtest_run(direction, &iface, &urls)
}

fn shell_single_quote(s: &str) -> String {
    let mut out = String::from("'");
    for ch in s.chars() {
        if ch == '\'' {
            out.push_str("'\\''");
        } else {
            out.push(ch);
        }
    }
    out.push('\'');
    out
}

fn speedtest_run(direction: &str, iface: &str, urls: &[String]) -> Result<(), String> {
    let rx_path = format!("/sys/class/net/{iface}/statistics/rx_bytes");
    let tx_path = format!("/sys/class/net/{iface}/statistics/tx_bytes");
    let parallel = 8usize;
    let duration = Duration::from_secs(10);

    let mut children = Vec::new();
    for i in 0..parallel {
        let urls = urls.to_vec();
        let dir = direction.to_string();
        children.push(thread::spawn(move || {
            let deadline = Instant::now() + duration + Duration::from_secs(1);
            let mut idx = i;
            while Instant::now() < deadline {
                let target = &urls[idx % urls.len()];
                if dir == "down" {
                    let _ = Command::new("curl")
                        .args(["-fsS", "-o", "/dev/null", "--max-time", "3", target])
                        .status();
                } else {
                    // head from /dev/zero — avoids dd
                    let cmd = format!(
                        "head -c 16777216 /dev/zero | curl -fsS -o /dev/null -X POST --data-binary @- --max-time 3 {}",
                        shell_single_quote(target)
                    );
                    let _ = Command::new("bash").args(["-c", &cmd]).status();
                }
                idx += 1;
            }
        }));
    }

    let mut rx_before = read_sys_u64(&rx_path);
    let mut tx_before = read_sys_u64(&tx_path);
    let start = Instant::now();

    while start.elapsed() < duration {
        thread::sleep(Duration::from_secs(1));
        let rx_after = read_sys_u64(&rx_path);
        let tx_after = read_sys_u64(&tx_path);
        let bytes = if direction == "down" {
            rx_after.saturating_sub(rx_before)
        } else {
            tx_after.saturating_sub(tx_before)
        };
        let mbps = (bytes as f64) * 8.0 / 1_000_000.0;
        if mbps < 10.0 {
            println!("{mbps:.1}");
        } else {
            println!("{mbps:.0}");
        }
        let _ = io::stdout().flush();
        rx_before = rx_after;
        tx_before = tx_after;
    }

    for c in children {
        let _ = c.join();
    }
    Ok(())
}

fn atty_stdin() -> bool {
    use std::io::IsTerminal;
    io::stdin().is_terminal()
}
