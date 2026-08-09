import QtQuick
import "../../config" as Config

Item {
    id: root

    required property var contentModel
    required property var palette

    readonly property real preferredWidth: clockText.implicitWidth
    readonly property real preferredHeight: Config.IslandConstants.clockHeight

    Text {
        id: clockText
        anchors.centerIn: parent
        color: root.palette.surfaceForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.clockFontSize
        font.weight: Font.Medium
        text: root.contentModel?.text ?? ""
    }

}
