import QtQuick
import QtQuick.Layouts
import qs.shared.theme

Item {
    id: root

    width: Constants.calendarWidth
    implicitHeight: content.implicitHeight

    property bool open: false
    property date currentDate: new Date()
    property date selectedDate: new Date()
    property date visibleMonth: new Date(
        currentDate.getFullYear(),
        currentDate.getMonth(),
        1
    )
    property int pendingMonthOffset: 0
    property int monthTransitionDirection: 1

    opacity: entrance.revealProgress
    scale: Constants.popupFromScale + entrance.revealProgress * (1 - Constants.popupFromScale)
    transformOrigin: Item.Top

    onOpenChanged: {
        if (open)
            entrance.play()
        else
            entrance.reset()
    }

    Component.onCompleted: {
        if (open)
            entrance.play()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.open ? Constants.popupEnterMs : Constants.popupExitMs
            easing.type: Easing.OutCubic
        }
    }

    QtObject {
        id: entrance

        property real revealProgress: 0

        function play() {
            reset()
            Qt.callLater(() => {
                if (root.open)
                    revealProgress = 1
            })
        }

        function reset() {
            revealProgress = 0
        }
    }

    function changeMonth(offset) {
        if (monthTransition.running)
            return

        pendingMonthOffset = offset
        monthTransitionDirection = offset < 0 ? -1 : 1
        monthTransition.start()
    }

    function sameDay(first, second) {
        return first.getFullYear() === second.getFullYear()
            && first.getMonth() === second.getMonth()
            && first.getDate() === second.getDate()
    }

    ColumnLayout {
        id: content

        width: parent.width
        spacing: Constants.spacingMd

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: Constants.calendarMainHeight
            radius: Constants.panelRadius
            color: Colors.surfaceContainerLow
            clip: true

            border {
                width: Constants.borderWidth
                color: Colors.surfaceContainerHighest
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Constants.paddingMd
                spacing: Constants.spacingMd

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: Constants.calendarHeaderHeight
                    radius: Constants.buttonRadius
                    color: Colors.surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.paddingMd
                        anchors.rightMargin: Constants.paddingMd
                        spacing: Constants.spacingMd

                        Rectangle {
                            Layout.preferredWidth: Constants.calendarNavigationSize
                            Layout.preferredHeight: Constants.calendarNavigationSize
                            radius: Constants.buttonRadius
                            color: previousArea.containsMouse
                                ? Colors.surfaceContainerHighest
                                : "transparent"

                            ThemeIcon {
                                anchors.centerIn: parent
                                name: "chevron-left"
                                iconSize: Constants.iconSizeLg
                                iconColor: Colors.surfaceForeground
                            }

                            MouseArea {
                                id: previousArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.changeMonth(-1)
                            }

                            Behavior on color {
                                ColorAnimation { duration: Constants.animationFast }
                            }
                        }

                        Text {
                            id: monthTitle

                            Layout.fillWidth: true
                            text: Qt.formatDateTime(root.visibleMonth, "MMMM, yyyy")
                            color: Colors.surfaceForeground
                            horizontalAlignment: Text.AlignHCenter

                            transform: Translate {
                                id: monthTitleShift
                            }

                            font {
                                family: Constants.fontFamily
                                pixelSize: Constants.fontSizeLg
                                weight: Font.DemiBold
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: Constants.calendarNavigationSize
                            Layout.preferredHeight: Constants.calendarNavigationSize
                            radius: Constants.buttonRadius
                            color: nextArea.containsMouse
                                ? Colors.surfaceContainerHighest
                                : "transparent"

                            ThemeIcon {
                                anchors.centerIn: parent
                                name: "chevron-right"
                                iconSize: Constants.iconSizeLg
                                iconColor: Colors.surfaceForeground
                            }

                            MouseArea {
                                id: nextArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.changeMonth(1)
                            }

                            Behavior on color {
                                ColorAnimation { duration: Constants.animationFast }
                            }
                        }
                    }
                }

                Rectangle {
                    id: calendarBody

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Constants.buttonRadius
                    color: "transparent"

                    transform: Translate {
                        id: calendarBodyShift
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Constants.paddingSm
                        spacing: Constants.spacingXs

                        GridLayout {
                            Layout.fillWidth: true
                            columns: Constants.calendarColumns
                            columnSpacing: 0
                            rowSpacing: 0

                            Repeater {
                                model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]

                                delegate: Item {
                                    Layout.fillWidth: true
                                    implicitHeight: Constants.calendarWeekdayHeight

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: Colors.surfaceVariantForeground

                                        font {
                                            family: Constants.fontFamily
                                            pixelSize: Constants.fontSizeSm
                                            weight: Font.Medium
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: Constants.borderWidth
                            color: Colors.outlineVariant
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            columns: Constants.calendarColumns
                            columnSpacing: 0
                            rowSpacing: Constants.spacingSm

                            Repeater {
                                model: Constants.calendarCellCount

                                delegate: Item {
                                    id: dayCell

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    property int firstDay: (new Date(
                                        root.visibleMonth.getFullYear(),
                                        root.visibleMonth.getMonth(),
                                        1
                                    ).getDay() + 6) % Constants.calendarColumns

                                    property int daysCurrent: new Date(
                                        root.visibleMonth.getFullYear(),
                                        root.visibleMonth.getMonth() + 1,
                                        0
                                    ).getDate()

                                    property int previousMonthDays: new Date(
                                        root.visibleMonth.getFullYear(),
                                        root.visibleMonth.getMonth(),
                                        0
                                    ).getDate()

                                    property int offset: index - firstDay + 1
                                    property bool fromPrevious: offset <= 0
                                    property bool fromNext: offset > daysCurrent
                                    property int dayNumber: fromPrevious
                                        ? previousMonthDays + offset
                                        : fromNext ? offset - daysCurrent : offset

                                    property date representedDate: new Date(
                                        root.visibleMonth.getFullYear(),
                                        root.visibleMonth.getMonth()
                                            + (fromPrevious ? -1 : fromNext ? 1 : 0),
                                        dayNumber
                                    )

                                    property bool isToday: root.sameDay(
                                        representedDate,
                                        root.currentDate
                                    )
                                    property bool selected: root.sameDay(
                                        representedDate,
                                        root.selectedDate
                                    )

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Constants.calendarDaySize
                                        height: Constants.calendarDaySize
                                        radius: Constants.buttonRadius
                                        color: dayCell.selected
                                            ? Colors.primaryContainer
                                            : dayArea.containsMouse
                                                ? Colors.surfaceContainerHighest
                                                : "transparent"

                                        border {
                                            width: dayCell.isToday && !dayCell.selected
                                                ? Constants.borderWidth
                                                : 0
                                            color: Colors.primary
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: dayCell.dayNumber
                                            color: dayCell.selected
                                                ? Colors.primaryContainerForeground
                                                : dayCell.fromPrevious || dayCell.fromNext
                                                    ? Colors.outline
                                                    : dayCell.isToday
                                                        ? Colors.primary
                                                        : Colors.surfaceForeground

                                            font {
                                                family: Constants.fontFamily
                                                pixelSize: Constants.fontSizeMd
                                                weight: dayCell.selected || dayCell.isToday
                                                    ? Font.DemiBold
                                                    : Font.Normal
                                            }
                                        }

                                        MouseArea {
                                            id: dayArea

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                root.selectedDate = dayCell.representedDate

                                                if (dayCell.fromPrevious || dayCell.fromNext) {
                                                    root.visibleMonth = new Date(
                                                        dayCell.representedDate.getFullYear(),
                                                        dayCell.representedDate.getMonth(),
                                                        1
                                                    )
                                                }
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation { duration: Constants.animationFast }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        SequentialAnimation {
            id: monthTransition

            ParallelAnimation {
                NumberAnimation {
                    target: monthTitleShift
                    property: "x"
                    to: -root.monthTransitionDirection
                        * Constants.calendarMonthSlideDistance
                    duration: Constants.animationFast
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: calendarBodyShift
                    property: "x"
                    to: -root.monthTransitionDirection
                        * Constants.calendarMonthSlideDistance
                    duration: Constants.animationFast
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: monthTitle
                    property: "opacity"
                    to: 0
                    duration: Constants.animationFast
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: calendarBody
                    property: "opacity"
                    to: 0
                    duration: Constants.animationFast
                    easing.type: Easing.InCubic
                }
            }

            ScriptAction {
                script: {
                    root.visibleMonth = new Date(
                        root.visibleMonth.getFullYear(),
                        root.visibleMonth.getMonth() + root.pendingMonthOffset,
                        1
                    )
                    monthTitleShift.x = root.monthTransitionDirection
                        * Constants.calendarMonthSlideDistance
                    calendarBodyShift.x = root.monthTransitionDirection
                        * Constants.calendarMonthSlideDistance
                }
            }

            ParallelAnimation {
                NumberAnimation {
                    target: monthTitleShift
                    property: "x"
                    to: 0
                    duration: Constants.animationNormal
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: calendarBodyShift
                    property: "x"
                    to: 0
                    duration: Constants.animationNormal
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: monthTitle
                    property: "opacity"
                    to: 1
                    duration: Constants.animationNormal
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: calendarBody
                    property: "opacity"
                    to: 1
                    duration: Constants.animationNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

    }
}
