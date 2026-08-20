import QtQuick
import qs.shared.theme

Item {
    id: root

    property bool recording: false
    signal clicked()

    visible: recording
    implicitWidth: recording ? Math.max(Constants.buttonSize, recRow.implicitWidth + 10) : 0
    implicitHeight: Constants.buttonSize
    opacity: recording ? 1 : 0
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: Constants.animationFast }
    }

    Rectangle {
        anchors.fill: parent
        radius: Constants.buttonRadius
        color: pointer.containsMouse
            ? Tokens.withAlpha(Colors.error, 0.28)
            : Tokens.withAlpha(Colors.error, 0.18)
        border.width: 1
        border.color: Colors.error
        visible: root.recording

        Row {
            id: recRow
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 7
                height: 7
                radius: 4
                color: Colors.error
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: root.recording
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 550 }
                    NumberAnimation { to: 1.0; duration: 550 }
                }
            }

            Text {
                text: "REC"
                color: Colors.error
                font.family: Constants.fontFamily
                font.pixelSize: Constants.fontSizeXs
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
