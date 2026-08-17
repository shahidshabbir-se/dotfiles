import QtQuick
import Quickshell.Io
import qs.shared.theme

Item {
    id: root

    required property string name
    property color iconColor: Colors.surfaceForeground
    property int iconSize: Constants.iconSizeMd

    readonly property string svg: iconFile.text().replace(
        /currentColor/g,
        root.iconColor
    )

    implicitWidth: iconSize
    implicitHeight: iconSize

    FileView {
        id: iconFile

        path: Qt.resolvedUrl("assets/icons/" + root.name + ".svg")
    }

    Image {
        anchors.fill: parent
        sourceSize.width: root.iconSize
        sourceSize.height: root.iconSize
        source: root.svg.length > 0
            ? "data:image/svg+xml;charset=utf-8,"
                + encodeURIComponent(root.svg)
            : ""
        mipmap: true
    }
}
