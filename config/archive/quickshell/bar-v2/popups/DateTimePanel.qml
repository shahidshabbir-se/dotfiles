import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration
import "."

Scope {
    id: root

    property bool open: false
    property var barRef: null

    property int calendarYear: 0
    property int calendarMonth: 0

    property string weatherLocation: "—"
    property string weatherCondition: "Loading…"
    property string weatherTemp: "—"
    property string weatherFeelsLike: "—"
    property string weatherHumidity: "—"
    property string weatherWind: "—"
    property bool weatherReady: false

    property string uptimeDuration: "—"
    property string uptimeSince: ""

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    readonly property int panelWidth: 680
    readonly property int panelHeight: 448

    signal closed()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property var now: clock.date ?? new Date()

    function close() {
        if (!open)
            return
        closed()
    }

    function syncCalendarToToday() {
        const today = root.now
        calendarYear = today.getFullYear()
        calendarMonth = today.getMonth()
    }

    function monthLabel(year, month) {
        return Qt.formatDate(new Date(year, month, 1), "MMMM yyyy")
    }

    function weekdayLabels() {
        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    function calendarCells() {
        const year = calendarYear
        const month = calendarMonth
        const first = firstWeekday(year, month)
        const days = daysInMonth(year, month)
        const prevDays = daysInMonth(year, month - 1)
        const cells = []

        for (let i = 0; i < first; i++) {
            const day = prevDays - first + i + 1
            cells.push({
                day,
                inMonth: false,
                isToday: false,
            })
        }

        const today = root.now
        for (let day = 1; day <= days; day++) {
            cells.push({
                day,
                inMonth: true,
                isToday: today.getFullYear() === year
                    && today.getMonth() === month
                    && today.getDate() === day,
            })
        }

        while (cells.length % 7 !== 0 || cells.length < 42) {
            const day = cells.length - first - days + 1
            cells.push({
                day,
                inMonth: false,
                isToday: false,
            })
        }

        return cells.slice(0, 42)
    }

    function firstWeekday(year, month) {
        const day = new Date(year, month, 1).getDay()
        return (day + 6) % 7
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function shiftCalendar(delta) {
        let month = calendarMonth + delta
        let year = calendarYear

        while (month < 0) {
            month += 12
            year -= 1
        }
        while (month > 11) {
            month -= 12
            year += 1
        }

        calendarMonth = month
        calendarYear = year
    }

    function stripUnit(value) {
        return (value ?? "").replace(/[^\d.-]/g, "")
    }

    function refreshWeather() {
        weatherProcess.running = false
        weatherProcess.running = true
    }

    function refreshUptime() {
        uptimeProcess.running = false
        uptimeProcess.running = true
    }

    function parseWeatherOutput(text) {
        const lines = text.trim().split("\n").map(line => line.trim()).filter(line => line.length > 0)
        if (lines.length < 4)
            return

        weatherLocation = lines[0] ?? "—"
        weatherCondition = lines[1] ?? "—"
        weatherTemp = stripUnit(lines[2] ?? "") + "°"
        weatherFeelsLike = stripUnit(lines[3] ?? "") + "°"
        weatherHumidity = stripUnit(lines[4] ?? "") + "%"
        weatherWind = stripUnit(lines[5] ?? "") + " km/h"
        weatherReady = true
    }

    function parseUptimeOutput(text) {
        const lines = text.trim().split("\n").map(line => line.trim()).filter(line => line.length > 0)
        uptimeDuration = lines[0] ?? "—"
        uptimeSince = lines[1] ?? ""
    }

    onOpenChanged: {
        if (open) {
            syncCalendarToToday()
            refreshWeather()
            refreshUptime()
        }
    }

    Component.onCompleted: syncCalendarToToday()

    Process {
        id: weatherProcess
        running: false
        command: ["bash", Quickshell.shellPath("scripts/fetch-weather.sh")]

        stdout: StdioCollector {
            onStreamFinished: root.parseWeatherOutput(text)
        }
    }

    Process {
        id: uptimeProcess
        running: false
        command: ["bash", Quickshell.shellPath("scripts/fetch-uptime.sh")]

        stdout: StdioCollector {
            onStreamFinished: root.parseUptimeOutput(text)
        }
    }

    Timer {
        interval: 60000
        running: root.open
        repeat: true
        onTriggered: root.refreshUptime()
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: root.refreshWeather()
    }

    LazyLoader {
        active: root.open

        Scope {
            PopupDismissGrab {
                active: root.open
                panelWindow: panelWindow
                barRef: root.barRef
                screen: root.activeScreen
                onDismissed: root.close()
            }

            PanelWindow {
                id: panelWindow
                screen: root.activeScreen
                visible: root.open && root.activeScreen !== null
                color: "transparent"
                aboveWindows: true
                focusable: true
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell_datetime_popup"
                WlrLayershell.keyboardFocus: visible
                    ? WlrKeyboardFocus.OnDemand
                    : WlrKeyboardFocus.None

                anchors {
                    top: true
                    left: true
                }

                margins {
                    top: BarMetrics.popupTopMargin
                    left: root.activeScreen
                        ? Math.max(16, Math.round((root.activeScreen.width - root.panelWidth) / 2))
                        : 16
                }

                implicitWidth: root.panelWidth
                implicitHeight: root.panelHeight
                width: implicitWidth
                height: implicitHeight

                onVisibleChanged: if (visible) popupFocus.refocus()

                PopupFocusHost {
                    id: popupFocus
                    active: root.open
                    anchors.fill: parent
                    onEscapePressed: root.close()

                    Item {
                        id: panelShell
                        anchors.fill: parent

                        Canvas {
                            id: caret
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            width: 18
                            height: 10

                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.reset()
                                ctx.beginPath()
                                ctx.moveTo(width / 2, 0)
                                ctx.lineTo(width, height)
                                ctx.lineTo(0, height)
                                ctx.closePath()
                                ctx.fillStyle = Colors.notificationPanelBackground
                                ctx.fill()
                            }

                            Component.onCompleted: requestPaint()
                        }

                        Rectangle {
                            id: panelBody
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 9
                            radius: 16
                            color: Colors.notificationPanelBackground
                            border.width: 1
                            border.color: Colors.notificationPanelBorder
                            implicitHeight: panelContent.implicitHeight + 40

                            ColumnLayout {
                                id: panelContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 16

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 16

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 1
                                        spacing: 12

                                        DateTimeCard {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 118

                                            Text {
                                                text: Qt.formatDateTime(root.now, "dddd")
                                                font.family: "Outfit"
                                                font.pixelSize: 12
                                                color: Colors.matugen.primary
                                            }

                                            Text {
                                                text: Qt.formatDateTime(root.now, "d MMMM")
                                                font.family: "Outfit"
                                                font.pixelSize: 34
                                                font.weight: Font.Bold
                                                color: Colors.textPrimary
                                            }

                                            Text {
                                                text: Qt.formatDateTime(root.now, "yyyy")
                                                font.family: "Outfit"
                                                font.pixelSize: 14
                                                color: Colors.textSecondary
                                            }
                                        }

                                        DateTimeCard {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 92

                                            SectionHeader {
                                                label: "Next Event"
                                                iconSource: "../assets/svg/calendar.svg"
                                            }

                                            Text {
                                                text: "No upcoming events"
                                                font.family: "Outfit"
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                                color: Colors.textPrimary
                                            }

                                            Text {
                                                text: "Connect a calendar to show events"
                                                font.family: "Outfit"
                                                font.pixelSize: 11
                                                color: Colors.textMuted
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }

                                        DateTimeCard {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 92

                                            SectionHeader {
                                                label: "System Uptime"
                                                iconSource: "../assets/svg/calendar.svg"
                                                usePulseDot: true
                                            }

                                            Text {
                                                text: root.uptimeDuration
                                                font.family: "Outfit"
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                                color: Colors.textPrimary
                                            }

                                            Text {
                                                text: root.uptimeSince
                                                font.family: "Outfit"
                                                font.pixelSize: 11
                                                color: Colors.textMuted
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 1
                                        spacing: 12

                                        DateTimeCard {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 248

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8

                                                NavButton {
                                                    onClicked: root.shiftCalendar(-1)
                                                }

                                                Text {
                                                    Layout.fillWidth: true
                                                    horizontalAlignment: Text.AlignHCenter
                                                    text: root.monthLabel(root.calendarYear, root.calendarMonth)
                                                    font.family: "Outfit"
                                                    font.pixelSize: 13
                                                    font.weight: Font.Medium
                                                    color: Colors.textPrimary
                                                }

                                                NavButton {
                                                    mirror: true
                                                    onClicked: root.shiftCalendar(1)
                                                }
                                            }

                                            GridLayout {
                                                Layout.fillWidth: true
                                                columns: 7
                                                rowSpacing: 4
                                                columnSpacing: 4

                                                Repeater {
                                                    model: root.weekdayLabels()
                                                    delegate: Text {
                                                        Layout.fillWidth: true
                                                        horizontalAlignment: Text.AlignHCenter
                                                        text: modelData
                                                        font.family: "Outfit"
                                                        font.pixelSize: 10
                                                        color: Colors.textMuted
                                                    }
                                                }

                                                Repeater {
                                                    model: root.calendarCells()
                                                    delegate: Item {
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: 28

                                                        readonly property var cell: modelData

                                                        Rectangle {
                                                            anchors.centerIn: parent
                                                            width: 26
                                                            height: 26
                                                            radius: 8
                                                            visible: cell.isToday
                                                            color: Colors.matugen.primary
                                                        }

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: cell.day
                                                            font.family: "Outfit"
                                                            font.pixelSize: 11
                                                            font.weight: cell.isToday ? Font.DemiBold : Font.Normal
                                                            color: cell.isToday
                                                                ? Colors.matugen.primaryForeground
                                                                : (cell.inMonth ? Colors.textPrimary : Colors.textMuted)
                                                            opacity: cell.inMonth ? 1 : 0.45
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        DateTimeCard {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 118

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 14

                                                ColumnLayout {
                                                    spacing: 4

                                                    RowLayout {
                                                        spacing: 10

                                                        Item {
                                                            width: 34
                                                            height: 34

                                                            Image {
                                                                id: weatherIcon
                                                                anchors.fill: parent
                                                                source: "../assets/svg/weather.svg"
                                                                sourceSize: Qt.size(48, 48)
                                                                fillMode: Image.PreserveAspectFit
                                                            }

                                                            ColorOverlay {
                                                                anchors.fill: weatherIcon
                                                                source: weatherIcon
                                                                color: Colors.matugen.primary
                                                            }
                                                        }

                                                        Text {
                                                            text: root.weatherTemp
                                                            font.family: "Outfit"
                                                            font.pixelSize: 28
                                                            font.weight: Font.Bold
                                                            color: Colors.textPrimary
                                                        }
                                                    }

                                                    Text {
                                                        text: root.weatherCondition
                                                        font.family: "Outfit"
                                                        font.pixelSize: 12
                                                        color: Colors.textSecondary
                                                    }

                                                    Text {
                                                        text: root.weatherLocation
                                                        font.family: "Outfit"
                                                        font.pixelSize: 11
                                                        color: Colors.textMuted
                                                        elide: Text.ElideRight
                                                        Layout.maximumWidth: 180
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 8

                                                    WeatherStat {
                                                        label: "Feels like"
                                                        value: root.weatherFeelsLike
                                                    }
                                                    WeatherStat {
                                                        label: "Humidity"
                                                        value: root.weatherHumidity
                                                    }
                                                    WeatherStat {
                                                        label: "Wind"
                                                        value: root.weatherWind
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component DateTimeCard: Rectangle {
        default property alias content: cardColumn.data

        radius: 12
        color: Colors.notificationCardBackground
        implicitHeight: cardColumn.implicitHeight + 24

        ColumnLayout {
            id: cardColumn
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6
        }
    }

    component SectionHeader: RowLayout {
        property string label
        property string iconSource
        property bool usePulseDot: false

        spacing: 6

        Item {
            visible: usePulseDot
            width: 8
            height: 8

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 4
                color: Colors.matugen.primary
                opacity: 0.35
            }

            Rectangle {
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: Colors.matugen.primary
            }
        }

        Item {
            visible: !usePulseDot
            width: 14
            height: 14

            Image {
                id: headerIcon
                anchors.fill: parent
                source: iconSource
                sourceSize: Qt.size(24, 24)
                fillMode: Image.PreserveAspectFit
            }

            ColorOverlay {
                anchors.fill: headerIcon
                source: headerIcon
                color: Colors.matugen.primary
            }
        }

        Text {
            text: label
            font.family: "Outfit"
            font.pixelSize: 11
            color: Colors.matugen.primary
        }
    }

    component WeatherStat: RowLayout {
        property string label
        property string value

        spacing: 8

        Text {
            Layout.preferredWidth: 72
            text: label
            font.family: "Outfit"
            font.pixelSize: 11
            color: Colors.textMuted
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            text: value
            font.family: "Outfit"
            font.pixelSize: 11
            font.weight: Font.Medium
            color: Colors.textPrimary
        }
    }

    component NavButton: Item {
        id: navRoot
        property bool mirror: false
        signal clicked()

        width: 24
        height: 24

        Rectangle {
            anchors.fill: parent
            radius: 8
            color: navHover.hovered ? Colors.moduleBackgroundHover : "transparent"
        }

        Text {
            anchors.centerIn: parent
            text: mirror ? "›" : "‹"
            font.pixelSize: 16
            color: Colors.textSecondary
        }

        HoverHandler { id: navHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: navRoot.clicked()
        }
    }
}
