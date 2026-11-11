import QtQuick
import qs.Commons as Commons
import qs.Ui as Ui

Ui.BarWidget {
    id: root

    property string format: "ddd HH:mm"
    property date now: new Date()
    property var barScreen: null

    Item {
        implicitWidth: label.implicitWidth
        implicitHeight: label.implicitHeight

        Text {
            id: label

            anchors.centerIn: parent
            color: Commons.Color.foreground
            text: Commons.Util.clockText(root.now, root.format)
            font {
                family: Commons.Style.fontFamily
                pixelSize: Commons.Style.fontSizeMd
                weight: Font.Medium
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: CalendarState.toggleCalendar(root.barScreen)
        }
    }

    CalendarPopup {
        barScreen: root.barScreen
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
