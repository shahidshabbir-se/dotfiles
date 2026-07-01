import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.configuration

RowLayout {
    spacing: 10

    readonly property var window: Hyprland.activeToplevel
    readonly property string wlClass: {
        if (!window) return ""
        const ipc = window.lastIpcObject || {}
        return (ipc.class || ipc.initialClass || window.wayland?.appId || "").toString().trim()
    }
    readonly property string classKey: wlClass.toLowerCase()
    readonly property string title: {
        if (!window) return ""
        return (window.title || "").trim()
    }
    readonly property string displayText: {
        if (title.length > 0) return title
        return appDisplay(classKey, "")
    }
    readonly property string fallbackGlyph: appIcon(classKey)

    property string iconPath: ""
    property string iconLookupKey: ""
    property var iconCache: ({})

    visible: window !== null && (displayText.length > 0 || classKey.length > 0)

    function iconLookupKeyForClass(key) {
        switch (key) {
        case "firefox":
        case "org.mozilla.firefox":
            return "zen-beta"
        default:
            return key
        }
    }

    function refreshIcon() {
        const key = classKey
        if (!key) {
            iconPath = ""
            return
        }

        const lookupKey = iconLookupKeyForClass(key)

        if (iconCache.hasOwnProperty(lookupKey)) {
            iconPath = iconCache[lookupKey]
            return
        }

        iconPath = ""
        iconLookupKey = lookupKey
        iconFinder.running = false
        iconFinder.running = true
    }

    function appDisplay(key, fallback) {
        switch (key) {
        case "dev.zed.zed": return "Zed"
        case "zen-beta":
        case "zen":
        case "firefox":
        case "org.mozilla.firefox": return "Zen Browser"
        case "brave-browser":
        case "brave": return "Brave Browser"
        case "google-chrome":
        case "chromium":
        case "chromium-browser": return "Chromium"
        case "com.mitchellh.ghostty":
        case "ghostty": return "Ghostty"
        case "code":
        case "codium":
        case "code-oss": return "Code"
        case "spotify": return "Spotify"
        case "org.gnome.nautilus":
        case "nautilus": return "Files"
        default: return fallback
        }
    }

    function appIcon(key) {
        switch (key) {
        case "brave-browser":
        case "brave":
        case "google-chrome":
        case "chromium": return "\uf268"
        case "firefox":
        case "org.mozilla.firefox": return "\uf269"
        case "com.mitchellh.ghostty":
        case "ghostty": return "\ue795"
        case "code":
        case "codium":
        case "code-oss": return "\uf0a8c"
        case "spotify": return "\uf1bc"
        case "org.gnome.nautilus":
        case "nautilus": return "\uf07b"
        default: return "\uf2d0"
        }
    }

    Process {
        id: iconFinder
        running: false
        command: ["bash", Quickshell.shellPath("scripts/find-icon.sh"), iconLookupKey]

        stdout: SplitParser {
            onRead: path => {
                const key = iconLookupKey
                const result = path.trim().length > 0 ? "file://" + path.trim() : ""
                iconCache[key] = result
                if (key === iconLookupKeyForClass(classKey))
                    iconPath = result
            }
        }

        onExited: {
            const key = iconLookupKey
            if (!iconCache.hasOwnProperty(key))
                iconCache[key] = ""
            if (key === iconLookupKeyForClass(classKey))
                iconPath = iconCache[key]
        }
    }

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() { refreshIcon() }
    }

    Connections {
        target: Hyprland.activeToplevel
        function onLastIpcObjectChanged() { refreshIcon() }
    }

    onClassKeyChanged: refreshIcon()
    Component.onCompleted: refreshIcon()

    Item {
        width: 16
        height: 16

        Image {
            anchors.centerIn: parent
            width: 16
            height: 16
            source: iconPath
            visible: iconPath !== ""
            sourceSize: Qt.size(32, 32)
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            antialiasing: true
        }

        Text {
            anchors.centerIn: parent
            text: fallbackGlyph
            visible: iconPath === ""
            font.family: "Symbols Nerd Font Mono"
            font.pixelSize: 12
            color: Colors.textSecondary
        }
    }

    Text {
        Layout.maximumWidth: 200
        visible: displayText.length > 0
        text: displayText
        elide: Text.ElideRight
        font.family: "Cartograph CF"
        font.pixelSize: 13
        color: Colors.textPrimary
    }
}
