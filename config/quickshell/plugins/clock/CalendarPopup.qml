pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons as Commons
import qs.Ui as Ui

// Calendar popup for the clock. Opens on the bar's screen, navigates by month,
// and highlights today. Outside click and Escape are handled by Ui.Popup.
Ui.Popup {
    id: root

    property var barScreen: null

    readonly property int cellSize: 32
    readonly property int gridWidth: cellSize * 7 + Commons.Style.spacingXs * 6

    open: CalendarState.open
        && (CalendarState.screen === null || CalendarState.screen === root.barScreen)
    popupScreen: root.barScreen
    modal: true

    onDismissed: CalendarState.closeCalendar()

    Column {
        id: layout

        width: root.gridWidth
        spacing: Commons.Style.spacingSm

        RowLayout {
            width: parent.width
            height: 28
            spacing: Commons.Style.spacingSm

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: Commons.Style.widgetRadius
                color: previousArea.containsMouse
                    ? Commons.Color.selection
                    : Commons.Color.surfaceHigh

                Text {
                    anchors.centerIn: parent
                    text: "\u2039"
                    color: Commons.Color.foregroundBright
                    font {
                        family: Commons.Style.monoFontFamily
                        pixelSize: Commons.Style.fontSizeLg
                        weight: Font.Bold
                    }
                    textFormat: Text.PlainText
                }

                MouseArea {
                    id: previousArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: CalendarState.previousMonth()
                }
            }

            Text {
                Layout.fillWidth: true
                text: CalendarState.monthLabel
                color: Commons.Color.foregroundBright
                font {
                    family: Commons.Style.fontFamily
                    pixelSize: Commons.Style.fontSizeMd
                    weight: Font.DemiBold
                }
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: Commons.Style.widgetRadius
                color: nextArea.containsMouse
                    ? Commons.Color.selection
                    : Commons.Color.surfaceHigh

                Text {
                    anchors.centerIn: parent
                    text: "\u203a"
                    color: Commons.Color.foregroundBright
                    font {
                        family: Commons.Style.monoFontFamily
                        pixelSize: Commons.Style.fontSizeLg
                        weight: Font.Bold
                    }
                    textFormat: Text.PlainText
                }

                MouseArea {
                    id: nextArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: CalendarState.nextMonth()
                }
            }
        }

        Row {
            spacing: Commons.Style.spacingXs

            Repeater {
                model: CalendarState.weekdayNames

                delegate: Text {
                    required property string modelData

                    width: root.cellSize
                    text: modelData
                    color: Commons.Color.comment
                    font {
                        family: Commons.Style.fontFamily
                        pixelSize: Commons.Style.fontSizeSm
                        weight: Font.Medium
                    }
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Grid {
            columns: 7
            spacing: Commons.Style.spacingXs

            Repeater {
                model: CalendarState.cells

                delegate: Item {
                    id: dayCell

                    required property var modelData

                    width: root.cellSize
                    height: root.cellSize

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: dayCell.modelData.isToday
                            ? Commons.Color.blue
                            : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: dayCell.modelData.day
                        color: dayCell.modelData.isToday
                            ? Commons.Color.background
                            : dayCell.modelData.inMonth
                                ? Commons.Color.foreground
                                : Commons.Color.comment
                        font {
                            family: Commons.Style.fontFamily
                            pixelSize: Commons.Style.fontSizeSm
                            weight: dayCell.modelData.isToday ? Font.Bold : Font.Normal
                        }
                        textFormat: Text.PlainText
                    }
                }
            }
        }
    }
}
