function singleLine(value, maximumLength) {
    return String(value || "")
        .replace(/[\u0000-\u001f\u007f]/g, " ")
        .replace(/[\u0080-\u009f\u202a-\u202e\u2066-\u2069]/g, "")
        .replace(/[\u2028\u2029]/g, " ")
        .trim()
        .slice(0, maximumLength)
}

function body(value) {
    return String(value || "")
        .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, " ")
        .replace(/[\u0080-\u009f\u202a-\u202e\u2066-\u2069]/g, "")
        .replace(/[\u2028\u2029]/g, " ")
        .slice(0, 4096)
}

function safeIconName(value) {
    const name = singleLine(value, 128)
    return /^[A-Za-z0-9._-]+$/.test(name) ? name : ""
}

function friendlyTime(timestamp, now) {
    const elapsed = Math.max(0, Number(now) - Number(timestamp))
    const minutes = Math.floor(elapsed / 60000)

    if (minutes < 1)
        return "now"

    if (minutes < 60)
        return minutes + " min"

    const hours = Math.floor(minutes / 60)
    if (hours < 24)
        return hours + " hr"

    const date = new Date(timestamp)
    const current = new Date(now)
    const yesterday = new Date(current.getFullYear(), current.getMonth(), current.getDate() - 1)

    if (date >= yesterday)
        return "Yesterday"

    return Qt.formatDate(date, "MMM d")
}
