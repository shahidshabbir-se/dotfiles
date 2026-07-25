import QtQuick
import "../../config" as Config

Item {
    id: root

    required property var contentModel
    required property var palette

    readonly property real preferredWidth: workspaceText.implicitWidth
    readonly property real preferredHeight: Config.IslandConstants.clockHeight

    Text {
        id: workspaceText
        anchors.centerIn: parent
        color: root.palette.surfaceForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.clockFontSize
        font.weight: Font.Medium
        text: root.contentModel?.text ?? ""
    }

}
