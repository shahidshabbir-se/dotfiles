// Pure notification formatting and stack helpers. Kept free of Qt/Quickshell
// imports so the same functions can be exercised by node in tests/.

function cleanSingleLine(value, maximumLength) {
    const maximum = Number(maximumLength) > 0 ? Number(maximumLength) : 128
    return String(value || "")
        .replace(/[\u0000-\u001f\u007f]/g, " ")
        .replace(/[\u0080-\u009f\u202a-\u202e\u2066-\u2069]/g, "")
        .replace(/[\u2028\u2029]/g, " ")
        .trim()
        .slice(0, maximum)
}

function cleanBody(value) {
    return String(value || "")
        .replace(/\r\n?/g, "\n")
        .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, " ")
        .replace(/[\u0080-\u009f\u202a-\u202e\u2066-\u2069]/g, "")
        .replace(/\u2028/g, "\n")
        .replace(/\u2029/g, "\n")
        .slice(0, 4096)
        .trim()
}

function safeIconName(value) {
    const name = cleanSingleLine(value, 128)
    return /^[A-Za-z0-9._-]+$/.test(name) ? name : ""
}

function iconSource(appIcon, image, resolveIcon) {
    const candidates = [appIcon, image]

    for (let i = 0; i < candidates.length; i++) {
        const raw = String(candidates[i] || "").trim()
        if (raw.length === 0)
            continue
        if (raw.startsWith("http://") || raw.startsWith("https://"))
            return raw
        if (raw.startsWith("file:") || raw.startsWith("image:"))
            return raw
        if (raw.startsWith("/"))
            return "file://" + raw

        const name = safeIconName(raw)
        if (name.length > 0 && typeof resolveIcon === "function") {
            const resolved = resolveIcon(name)
            if (resolved)
                return resolved
        }
    }

    return ""
}

function visibleToasts(values, maximum) {
    const list = values ? Array.prototype.slice.call(values) : []
    const limit = Number(maximum) > 0 ? Number(maximum) : list.length
    return list.reverse().slice(0, limit)
}

function overflowedToasts(values, maximum) {
    const list = values ? Array.prototype.slice.call(values) : []
    const limit = Number(maximum) > 0 ? Number(maximum) : list.length
    const overflow = Math.max(0, list.length - limit)
    return list.slice(0, overflow)
}

function toastTimeout(expireTimeout, critical, defaultTimeout) {
    if (critical)
        return 0

    const explicit = Number(expireTimeout)
    if (explicit === 0)
        return 0
    if (explicit > 0)
        return Math.min(30000, Math.max(1000, explicit))

    return Number(defaultTimeout) > 0 ? Number(defaultTimeout) : 6000
}

function actionList(actions, maximum) {
    const list = actions ? Array.prototype.slice.call(actions) : []
    const limit = Number(maximum) > 0 ? Number(maximum) : list.length
    const result = []

    for (let i = 0; i < list.length && result.length < limit; i++) {
        const action = list[i]
        if (!action || String(action.text || "").trim().length === 0)
            continue
        result.push(action)
    }

    return result
}
