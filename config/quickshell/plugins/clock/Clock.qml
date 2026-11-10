import QtQuick
import "../../Commons"

Item {
    id: root

    property string format: "ddd HH:mm"
    property date now: new Date()

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label

        anchors.centerIn: parent
        color: Color.foreground
        text: Util.clockText(root.now, root.format)
        font {
            family: Style.fontFamily
            pixelSize: Style.fontSizeMd
            weight: Font.Medium
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
