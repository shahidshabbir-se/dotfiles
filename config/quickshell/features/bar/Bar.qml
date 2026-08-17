import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.shared.theme

PanelWindow {
    id: bar

    property int orientation: Qt.Horizontal
    property int notificationCount: 0
    property bool notificationCenterOpen: false
    property bool doNotDisturb: false
    readonly property bool vertical: orientation === Qt.Vertical

    signal notificationsClicked()
    signal popupOpened()

    function closePopups() {
        calendarWindow.visible = false
        musicWindow.visible = false
    }

    function togglePopup(popup) {
        const shouldOpen = !popup.visible

        closePopups()
        popup.visible = shouldOpen

        if (shouldOpen)
            popupOpened()
    }

    anchors {
        top: !bar.vertical
        left: bar.vertical
    }

    implicitWidth: bar.vertical
        ? Constants.barVerticalWidth
        : Math.min(screen.width * Constants.barWidthRatio, Constants.barMaxWidth)

    implicitHeight: bar.vertical
        ? screen.height * Constants.barHeightRatio
        : Constants.barHeight

    exclusiveZone: bar.vertical
        ? Constants.barVerticalWidth
        : Constants.barHeight

    margins {
        top: bar.vertical ? 0 : Constants.barTopMargin
        left: bar.vertical ? Constants.barTopMargin : 0
    }

    color: "transparent"

    Rectangle {
        id: barBackground

        anchors.fill: parent

        radius: Constants.barRadius
        color: Colors.surfaceContainerLow

        GridLayout {
            anchors.fill: parent
            anchors.margins: bar.vertical ? Constants.paddingSm : 0
            anchors.leftMargin: bar.vertical ? Constants.paddingSm : Constants.paddingMd
            anchors.rightMargin: bar.vertical ? Constants.paddingSm : Constants.paddingMd

            columns: bar.vertical ? 1 : 5
            columnSpacing: Constants.spacingMd
            rowSpacing: Constants.spacingMd

            // Left / top
            Workspaces {
                vertical: bar.vertical
                Layout.column: 0
                Layout.row: 0
                Layout.fillWidth: bar.vertical
                Layout.alignment: Qt.AlignHCenter
            }

            Item {
                Layout.fillWidth: !bar.vertical
                Layout.fillHeight: bar.vertical
                Layout.column: bar.vertical ? 0 : 1
                Layout.row: bar.vertical ? 1 : 0
            }

            Item {
                Layout.column: bar.vertical ? 0 : 2
                Layout.row: bar.vertical ? 2 : 0
            }

            Item {
                Layout.fillWidth: !bar.vertical
                Layout.fillHeight: bar.vertical
                Layout.column: bar.vertical ? 0 : 3
                Layout.row: bar.vertical ? 3 : 0
            }

            GridLayout {
                Layout.column: bar.vertical ? 0 : 4
                Layout.row: bar.vertical ? 4 : 0
                Layout.alignment: Qt.AlignCenter
                columns: bar.vertical ? 1 : 2
                columnSpacing: Constants.spacingXs
                rowSpacing: Constants.spacingXs

                NotificationButton {
                    count: bar.notificationCount
                    active: bar.notificationCenterOpen
                    doNotDisturb: bar.doNotDisturb

                    onClicked: {
                        bar.closePopups()
                        bar.notificationsClicked()
                    }
                }

                MusicButton {
                    id: music

                    onClicked: bar.togglePopup(musicWindow)
                }
            }

        }

        Clock {
            id: clock

            anchors.centerIn: parent
            vertical: bar.vertical

            onClicked: bar.togglePopup(calendarWindow)
        }
    }

    PopupWindow {
        id: calendarWindow

        anchor {
            item: clock
            rect.x: bar.vertical ? clock.width + Constants.spacingLg : 0
            rect.y: bar.vertical ? 0 : clock.height + Constants.spacingXl + Constants.spacingXs
            rect.width: bar.vertical ? 1 : clock.width
            rect.height: bar.vertical ? clock.height : 1
            edges: bar.vertical ? Edges.Bottom | Edges.Right : Edges.Bottom
            gravity: bar.vertical ? Edges.Top | Edges.Right : Edges.Bottom
        }

        implicitWidth: calendar.width
        implicitHeight: calendar.implicitHeight
        color: "transparent"
        grabFocus: true

        CalendarPopup {
            id: calendar
        }
    }

    PopupWindow {
        id: musicWindow

        anchor {
            item: bar.vertical ? music : barBackground
            rect.x: bar.vertical
                ? music.width + Constants.spacingLg
                : barBackground.width - 1
            rect.y: bar.vertical
                ? 0
                : (barBackground.height + clock.height) / 2
                    + Constants.spacingXl + Constants.spacingXs
            rect.width: 1
            rect.height: bar.vertical ? music.height : 1
            edges: bar.vertical
                ? Edges.Bottom | Edges.Right
                : Edges.Bottom | Edges.Right
            gravity: bar.vertical
                ? Edges.Top | Edges.Right
                : Edges.Bottom | Edges.Left
        }

        implicitWidth: musicPopup.width
        implicitHeight: musicPopup.implicitHeight
        color: "transparent"
        visible: false
        grabFocus: true

        MusicPopup {
            id: musicPopup
            open: musicWindow.visible
        }
    }

}
