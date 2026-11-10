.pragma library

// Pure shell-config parsing. Kept free of QML types so it can be exercised by
// qmltestrunner without starting a Quickshell process.
var SECTIONS = ["left", "centerBegin", "center", "centerEnd", "tray", "right"];
var POSITIONS = ["top", "bottom"];
var CONFIG_VERSION = 1;
var DEFAULT_WALLPAPER_DIRECTORY = "~/Pictures/Wallpapers";

function emptyLayout() {
    var layout = {};
    for (var i = 0; i < SECTIONS.length; i++)
        layout[SECTIONS[i]] = [];
    return layout;
}

function isObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
}

function copyObject(value) {
    var copy = {};
    for (var key in value)
        copy[key] = value[key];
    return copy;
}

function parse(text) {
    var errors = [];
    var result = {
        ok: false,
        version: 0,
        position: "top",
        layout: emptyLayout(),
        wallpaper: {
            directory: DEFAULT_WALLPAPER_DIRECTORY,
            file: ""
        },
        errors: errors
    };

    if (typeof text !== "string" || text.trim() === "") {
        errors.push("shell.json is empty");
        return result;
    }

    var root;
    try {
        root = JSON.parse(text);
    } catch (error) {
        errors.push("shell.json is not valid JSON: " + error.message);
        return result;
    }

    if (!isObject(root)) {
        errors.push("shell.json must be a JSON object");
        return result;
    }

    if (root.version !== CONFIG_VERSION) {
        errors.push("unsupported shell.json version: " + root.version
            + " (expected " + CONFIG_VERSION + ")");
    } else {
        result.version = CONFIG_VERSION;
    }

    if (isObject(root.wallpaper)) {
        if (typeof root.wallpaper.directory === "string")
            result.wallpaper.directory = root.wallpaper.directory;
        else if (root.wallpaper.directory !== undefined)
            errors.push("wallpaper.directory must be a string");

        if (typeof root.wallpaper.file === "string")
            result.wallpaper.file = root.wallpaper.file;
        else if (root.wallpaper.file !== undefined)
            errors.push("wallpaper.file must be a string");
    } else {
        errors.push("wallpaper block must be an object");
    }

    if (!isObject(root.bar)) {
        errors.push("bar block is missing or invalid");
        result.ok = errors.length === 0;
        return result;
    }

    if (POSITIONS.indexOf(root.bar.position) >= 0) {
        result.position = root.bar.position;
    } else {
        errors.push("bar.position must be one of " + POSITIONS.join(", "));
    }

    if (!isObject(root.bar.layout)) {
        errors.push("bar.layout is missing or invalid");
        result.ok = errors.length === 0;
        return result;
    }

    for (var s = 0; s < SECTIONS.length; s++) {
        var section = SECTIONS[s];
        var entries = root.bar.layout[section];

        if (!Array.isArray(entries)) {
            errors.push("bar.layout." + section + " must be an array");
            continue;
        }

        for (var e = 0; e < entries.length; e++) {
            var entry = entries[e];
            if (!isObject(entry)) {
                errors.push("bar.layout." + section + "[" + e + "] must be an object");
                continue;
            }
            if (typeof entry.id !== "string" || entry.id.trim() === "") {
                errors.push("bar.layout." + section + "[" + e + "] needs a non-empty string id");
                continue;
            }
            result.layout[section].push(copyObject(entry));
        }
    }

    result.ok = errors.length === 0;
    return result;
}

// Applies inline widget options to a loaded widget. Returns option names the
// widget does not declare, so the bar can report a bad layout entry instead of
// dropping it silently.
function applyOptions(target, entry, onUnknown) {
    var unknown = [];
    if (!target || !entry)
        return unknown;

    for (var key in entry) {
        if (key === "id")
            continue;
        if (typeof target[key] === "undefined") {
            unknown.push(key);
            if (onUnknown)
                onUnknown(key);
            continue;
        }
        target[key] = entry[key];
    }
    return unknown;
}
