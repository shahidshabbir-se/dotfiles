.pragma library

function sectionTitle(networks, index) {
    if (!Array.isArray(networks) || index < 0 || index >= networks.length)
        return ""
    const net = networks[index]
    if (!net)
        return ""
    if (net.known && index === 0)
        return "KNOWN NETWORKS"
    if (!net.known && (index === 0 || (networks[index - 1] && networks[index - 1].known)))
        return "OTHER NETWORKS"
    return ""
}

function canForget(network) {
    return !!(network && network.known && !network.connected)
}

function isSecured(security) {
    if (!security)
        return false
    const s = String(security).toUpperCase()
    return s !== "--" && s.indexOf("OPEN") < 0 && s !== "NOPASS"
}

function signalBars(strength) {
    const s = Math.max(0, Math.min(100, Number(strength) || 0))
    if (s <= 0)
        return 0
    if (s < 25)
        return 1
    if (s < 50)
        return 2
    if (s < 75)
        return 3
    return 4
}

function formatBytes(bytes) {
    const n = Number(bytes)
    if (!isFinite(n) || n < 0)
        return "—"
    if (n < 1024)
        return Math.round(n) + " B"
    if (n < 1024 * 1024)
        return (n / 1024).toFixed(n < 10 * 1024 ? 1 : 0) + " KB"
    if (n < 1024 * 1024 * 1024)
        return (n / (1024 * 1024)).toFixed(n < 10 * 1024 * 1024 ? 1 : 0) + " MB"
    return (n / (1024 * 1024 * 1024)).toFixed(2) + " GB"
}

function formatRate(bytesPerSec) {
    const n = Number(bytesPerSec)
    if (!isFinite(n) || n < 0)
        return "—"
    return formatBytes(n) + "/s"
}

function formatPing(ms) {
    const value = parseFloat(ms)
    if (!isFinite(value) || value < 0)
        return "—"
    return value.toFixed(value > 0 && value < 10 ? 1 : 0) + " ms"
}

function wifiIconFor(strength) {
    const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
    const index = Math.max(0, Math.min(4, Math.ceil(strength / 20) - 1))
    return icons[index]
}

function connectionIcon(kind, signalStrength) {
    if (kind === "wifi")
        return wifiIconFor(signalStrength)
    if (kind === "ethernet")
        return "󰈀"
    return "󰤮"
}

function bandLabel(band) {
    if (band === "auto")
        return "Auto"
    if (!band)
        return ""
    return band + " GHz"
}

function dnsLabel(provider) {
    if (provider === "dhcp")
        return "DHCP"
    if (provider === "cloudflare")
        return "Cloudflare"
    if (provider === "google")
        return "Google"
    return provider || "DNS"
}
