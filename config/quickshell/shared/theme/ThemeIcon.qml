import QtQuick
import QtQuick.Window
import Quickshell.Io
import qs.shared.theme

Item {
    id: root

    required property string name
    property color iconColor: Colors.surfaceForeground
    property int iconSize: Constants.iconSizeMd

    // Raster SVGs at physical pixels so HiDPI doesn't upscale a soft 16–18px bitmap.
    readonly property real dpr: {
        const window = root.Window.window
        if (window && window.screen)
            return Math.max(1, window.screen.devicePixelRatio)
        return Math.max(1, Screen.devicePixelRatio)
    }
    readonly property int rasterSize: Math.max(
        root.iconSize * 2,
        Math.ceil(root.iconSize * root.dpr)
    )

    readonly property string svg: iconFile.text().replace(
        /currentColor/g,
        root.iconColor
    )

    implicitWidth: iconSize
    implicitHeight: iconSize

    FileView {
        id: iconFile

        path: Qt.resolvedUrl("icons/" + root.name + ".svg")
    }

    Image {
        anchors.centerIn: parent
        width: root.iconSize
        height: root.iconSize
        sourceSize.width: root.rasterSize
        sourceSize.height: root.rasterSize
        // High-res raster, then scale down — sharper than mipmap upscale of tiny SVG.
        smooth: true
        mipmap: false
        antialiasing: true
        fillMode: Image.PreserveAspectFit
        asynchronous: false
        source: root.svg.length > 0
            ? "data:image/svg+xml;charset=utf-8,"
                + encodeURIComponent(root.svg)
            : ""
    }
}
