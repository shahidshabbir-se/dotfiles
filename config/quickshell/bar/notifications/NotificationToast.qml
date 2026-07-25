import QtQuick
import QtQuick.Layouts
import qs.configuration
import "."

Rectangle {
    id: root

    required property var entry
    signal activated()
    signal dismissed()
    signal expired()

    readonly property var source: entry.ref ?? entry
    readonly property string displaySummary: source.summary ?? ""
    readonly property string displayBody: source.body ?? ""

    width: BarMetrics.notificationPanelWidth
    radius: 10
    color: Colors.notificationPanelBackground
    implicitHeight: toastRow.implicitHeight + 24

    opacity: 0
    transform: Translate { id: slide; x: 40 }

    Component.onCompleted: enterAnimation.start()

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 240; easing.type: Easing.OutCubic }
        NumberAnimation { target: slide; property: "x"; from: 40; to: 0; duration: 240; easing.type: Easing.OutCubic }
    }

    RowLayout {
        id: toastRow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        NotificationIcon {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            source: root.source
            size: 32
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 18
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: displaySummary
                font.family: "Outfit"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: Colors.textPrimary
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                visible: displayBody.length > 0
                text: displayBody
                font.family: "Outfit"
                font.pixelSize: 12
                color: Colors.textSecondary
                elide: Text.ElideRight
                maximumLineCount: 2
                wrapMode: Text.WordWrap
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    Item {
        z: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 6
        width: 22
        height: 22

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: closeArea.containsMouse ? Colors.controlHover : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        Text {
            anchors.centerIn: parent
            text: "×"
            font.family: "Outfit"
            font.pixelSize: 16
            font.weight: Font.Medium
            color: closeArea.containsMouse ? Colors.textPrimary : Colors.textMuted
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }

    Timer {
        interval: BarMetrics.notificationToastHideMs
        running: true
        onTriggered: root.expired()
    }
}
