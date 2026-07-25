import QtQuick
import Qt5Compat.GraphicalEffects
import qs.configuration

Item {
    id: root

    required property var source
    property int size: 32

    property string iconPath: ""

    implicitWidth: size
    implicitHeight: size

    function normalizeIconKey(value) {
        const key = (value ?? "").trim().toLowerCase()
        if (key.length === 0)
            return ""
        if (key.includes("firefox") || key.includes("mozilla") || key.includes("zen"))
            return "zen-beta"
        return key
    }

    readonly property bool usesExplicitIcon: {
        const icon = (source?.appIcon ?? "").trim()
        return icon.startsWith("/") || icon.includes("://") || icon.includes("music.svg")
    }

    readonly property string lookupKey: {
        if (usesExplicitIcon)
            return ""

        const icon = (source?.appIcon ?? "").trim()
        if (icon.length > 0 && !icon.includes("/") && !icon.includes(":")) {
            const key = normalizeIconKey(icon)
            if (key.length > 0)
                return key
        }

        let name = (source?.appName ?? "").trim().toLowerCase()
        if (name.startsWith("."))
            name = name.slice(1)
        if (name.endsWith("-wrapped"))
            name = name.slice(0, -"-wrapped".length)
        return normalizeIconKey(name) || name
    }

    readonly property string fallbackGlyph: {
        const name = (source?.appName ?? "?").trim()
        return name.length > 0 ? name.charAt(0).toUpperCase() : "?"
    }

    readonly property bool showImage: iconPath.length > 0 && iconImage.status === Image.Ready
    readonly property bool tintMusicIcon: iconPath.includes("music.svg")

    function applyCachedPath(key) {
        if (!NotificationIconCache.hasEntry(key))
            return false
        iconPath = NotificationIconCache.pathFor(key) ?? ""
        return true
    }

    function toImageSource(value) {
        const raw = (value ?? "").trim()
        if (raw.length === 0)
            return ""
        if (raw.startsWith("/"))
            return "file://" + raw
        if (raw.includes("://"))
            return raw
        return ""
    }

    function refreshIcon() {
        const preview = toImageSource(source?.image)
        if (preview.length > 0) {
            iconPath = preview
            return
        }

        const icon = (source?.appIcon ?? "").trim()
        const iconSource = toImageSource(icon)
        if (iconSource.length > 0) {
            iconPath = iconSource
            return
        }

        const key = lookupKey
        if (key.length === 0) {
            iconPath = ""
            return
        }

        if (applyCachedPath(key))
            return

        iconPath = ""
        NotificationIconCache.warm(key)
    }

    Connections {
        target: NotificationIconCache
        function onPathsChanged() {
            if (root.usesExplicitIcon)
                return
            root.applyCachedPath(root.lookupKey)
        }
    }

    onSourceChanged: refreshIcon()
    Component.onCompleted: refreshIcon()

    Image {
        id: iconImage
        width: root.size
        height: root.size
        source: iconPath
        sourceSize: Qt.size(32, 32)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
        visible: showImage && !tintMusicIcon

        onStatusChanged: {
            if (status === Image.Error && !root.usesExplicitIcon) {
                const key = root.lookupKey
                if (key.length > 0)
                    NotificationIconCache.store(key, "")
                root.iconPath = ""
            }
        }
    }

    ColorOverlay {
        anchors.fill: parent
        source: iconImage
        visible: showImage && tintMusicIcon
        color: Colors.notificationAccent
    }

    Rectangle {
        anchors.fill: parent
        visible: !showImage
        radius: Math.round(size * 0.22)
        color: Colors.notificationIconBackground
        border.width: 1
        border.color: Colors.withAlpha(Colors.matugen.outline, 0.5)
    }

    Text {
        anchors.centerIn: parent
        visible: !showImage
        text: fallbackGlyph
        font.family: "Outfit"
        font.pixelSize: Math.round(size * 0.38)
        font.weight: Font.DemiBold
        color: Colors.notificationAccent
    }
}
