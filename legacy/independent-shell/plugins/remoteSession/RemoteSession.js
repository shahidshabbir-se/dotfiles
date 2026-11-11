// Pure remote-session classification helpers. Kept free of Qt/Quickshell
// imports so node can exercise the same decision table used by the shell.

function text(value) {
    if (value === undefined || value === null)
        return "";
    return String(value).trim();
}

function yes(value) {
    const normalized = text(value).toLowerCase();
    return normalized === "yes" || normalized === "true" || normalized === "1";
}

// loginctl prints "Key=Value" lines for the properties we ask for.
function parseLogind(output) {
    const result = {};
    const lines = String(output || "").split("\n");

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const separator = line.indexOf("=");
        if (separator <= 0)
            continue;
        const key = line.slice(0, separator).trim();
        if (key.length === 0)
            continue;
        result[key] = line.slice(separator + 1).trim();
    }

    return result;
}

// A remote X11 DISPLAY looks like "host:0" or "host:10.0". An empty host
// (":0"), a Unix socket ("unix:0"), or loopback is local.
function x11DisplayHost(display) {
    const value = text(display);
    if (value.length === 0)
        return "";
    const separator = value.lastIndexOf(":");
    if (separator <= 0)
        return "";
    const host = value.slice(0, separator).toLowerCase();
    if (host === "" || host === "unix" || host === "localhost"
            || host === "127.0.0.1" || host === "[::1]")
        return "";
    return host;
}

// input fields are all optional strings:
// sshConnection, sshClient, sshTty, remoteFlag, sessionType, sessionClass,
// service, display, tty.
function classify(input) {
    input = input || {};

    if (text(input.sshConnection).length > 0
            || text(input.sshClient).length > 0
            || text(input.sshTty).length > 0)
        return { remote: true, reason: "ssh" };

    if (yes(input.remoteFlag))
        return { remote: true, reason: "logind" };

    const service = text(input.service).toLowerCase();
    if (service === "sshd" || service === "sshd.service"
            || service.indexOf("sshd") === 0)
        return { remote: true, reason: "logind-service" };

    if (x11DisplayHost(input.display).length > 0)
        return { remote: true, reason: "x11-display" };

    if (text(input.sessionType).toLowerCase() === "tty")
        return { remote: true, reason: "tty" };

    return { remote: false, reason: "local" };
}

function summary(classification) {
    const value = classification || { remote: false, reason: "local" };
    return value.remote ? "remote session (" + value.reason + ")" : "local session";
}

function statusObject(input, classification) {
    input = input || {};
    const value = classification || classify(input);

    return {
        remote: Boolean(value.remote),
        reason: value.reason,
        summary: summary(value),
        sessionId: text(input.sessionId),
        sessionType: text(input.sessionType) || "unknown",
        sessionClass: text(input.sessionClass) || "unknown",
        service: text(input.service),
        ssh: text(input.sshConnection).length > 0
            || text(input.sshClient).length > 0
            || text(input.sshTty).length > 0,
        display: text(input.display),
        waylandDisplay: text(input.waylandDisplay),
        logindRemote: text(input.remoteFlag)
    };
}
