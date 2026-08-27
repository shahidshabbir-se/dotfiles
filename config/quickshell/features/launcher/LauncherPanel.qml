pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.shared.theme

PanelWindow {
    id: window

    property bool open: false
    property bool presented: false
    property string query: ""
    property int selectedIndex: 0

    signal closeRequested()

    readonly property var activeScreen: {
        const focused = Hyprland.focusedMonitor?.name ?? ""
        const match = Quickshell.screens.find(s => s && s.name === focused)
        return match || Quickshell.screens[0] || null
    }

    readonly property var allApps: {
        const apps = DesktopEntries.applications.values.filter(
            app => app && app.name && app.name.length > 0
        )
        return apps.slice().sort((a, b) => a.name.localeCompare(b.name))
    }

    readonly property var filteredApps: {
        const q = query.trim().toLowerCase()
        if (!q.length)
            return allApps

        return allApps.filter(app => {
            const haystack = [
                app.name || "",
                app.genericName || "",
                app.comment || "",
                (app.keywords || []).join(" "),
                (app.categories || []).join(" ")
            ].join(" ").toLowerCase()
            return haystack.indexOf(q) >= 0
        })
    }

    function iconSource(iconName) {
        const clean = String(iconName || "").split("?")[0]
        if (clean.length > 0) {
            const path = Quickshell.iconPath(clean, true)
            if (path && path.length > 0)
                return path
        }
        return Quickshell.iconPath("application-x-executable", true)
    }

    function clampSelection() {
        if (filteredApps.length === 0) {
            selectedIndex = 0
            return
        }
        selectedIndex = Math.max(0, Math.min(selectedIndex, filteredApps.length - 1))
    }

    function moveSelection(delta) {
        if (filteredApps.length === 0)
            return
        const n = filteredApps.length
        selectedIndex = (selectedIndex + delta + n) % n
        list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function activateSelected() {
        if (filteredApps.length === 0)
            return
        launch(filteredApps[selectedIndex])
    }

    function launch(entry) {
        if (!entry)
            return
        entry.execute()
        window.closeRequested()
    }

    function reset() {
        query = ""
        selectedIndex = 0
    }

    onFilteredAppsChanged: clampSelection()

    onOpenChanged: {
        if (open) {
            reset()
            exitHide.stop()
            if (!presented)
                presented = true
            entrance.play()
            Qt.callLater(() => searchField.forceActiveFocus())
        } else if (presented) {
            entrance.reset()
            exitHide.restart()
        }
    }

    screen: activeScreen
    visible: presented && activeScreen !== null
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: open
    surfaceFormat.opaque: false

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    mask: Region {
        width: window.open ? (window.screen ? window.screen.width : 1) : 0
        height: window.open ? (window.screen ? window.screen.height : 1) : 0
    }

    Timer {
        id: exitHide
        interval: Constants.popupExitMs
        onTriggered: {
            if (!window.open)
                window.presented = false
        }
    }

    QtObject {
        id: entrance
        property real revealProgress: 0

        function play() {
            reset()
            Qt.callLater(() => {
                if (window.open)
                    revealProgress = 1
            })
        }

        function reset() {
            revealProgress = 0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Tokens.withAlpha(Colors.shadow, 0.55 * entrance.revealProgress)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: window.closeRequested()
        }
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: Math.min(Constants.launcherWidth, parent.width - 32)
        // Size from content — include paddings + column spacing (old formula clipped the last row).
        readonly property int chromeHeight:
            Constants.paddingLg * 2 + Constants.spacingMd + searchBar.height
        readonly property int listNaturalHeight: window.filteredApps.length === 0
            ? Constants.launcherRowHeight
            : window.filteredApps.length * Constants.launcherRowHeight
                + Math.max(0, window.filteredApps.length - 1) * list.spacing
        height: Math.min(
            Constants.launcherMaxHeight,
            chromeHeight + listNaturalHeight
        )
        radius: Constants.panelRadius
        color: Colors.background
        border.width: Constants.borderWidth
        border.color: Colors.outlineVariant
        opacity: entrance.revealProgress
        scale: Constants.popupFromScale
            + entrance.revealProgress * (1 - Constants.popupFromScale)
        clip: true

        Behavior on opacity {
            NumberAnimation {
                duration: window.open ? Constants.popupEnterMs : Constants.popupExitMs
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: window.open ? Constants.popupEnterMs : Constants.popupExitMs
                easing.type: Easing.OutCubic
            }
        }

        // Swallow clicks so backdrop dismiss doesn't fire.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            z: -1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Constants.paddingLg
            spacing: Constants.spacingMd

            Rectangle {
                id: searchBar

                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: Colors.surfaceContainerHigh
                radius: Constants.panelRadius
                border.width: Constants.borderWidth
                border.color: searchField.activeFocus
                    ? Colors.primary
                    : Colors.outlineVariant

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Constants.paddingLg
                    anchors.rightMargin: Constants.paddingLg
                    spacing: Constants.spacingMd

                    Text {
                        text: "󰍉"
                        color: Colors.primary
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Constants.fontSizeLg
                    }

                    TextInput {
                        id: searchField

                        Layout.fillWidth: true
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: Constants.fontSizeMd
                        font.weight: Font.Medium
                        selectedTextColor: Colors.primaryForeground
                        selectionColor: Colors.primary
                        clip: true
                        focus: window.open
                        text: window.query

                        onTextChanged: {
                            if (window.query !== text)
                                window.query = text
                        }

                        Keys.onEscapePressed: window.closeRequested()
                        Keys.onDownPressed: window.moveSelection(1)
                        Keys.onUpPressed: window.moveSelection(-1)
                        Keys.onReturnPressed: window.activateSelected()
                        Keys.onEnterPressed: window.activateSelected()
                    }
                }
            }

            ListView {
                id: list

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: window.filteredApps
                currentIndex: window.selectedIndex
                keyNavigationEnabled: false

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width: list.width
                    height: Constants.launcherRowHeight
                    radius: Constants.panelRadius
                    color: {
                        if (window.selectedIndex === index)
                            return Colors.primary
                        if (hover.hovered)
                            return Colors.surfaceContainerHigh
                        return "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.paddingMd
                        anchors.rightMargin: Constants.paddingMd
                        spacing: Constants.spacingMd

                        Image {
                            Layout.preferredWidth: Constants.launcherIconSize
                            Layout.preferredHeight: Constants.launcherIconSize
                            sourceSize.width: Constants.launcherIconSize
                            sourceSize.height: Constants.launcherIconSize
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            smooth: true
                            source: window.iconSource(row.modelData.icon)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.name || ""
                                elide: Text.ElideRight
                                color: window.selectedIndex === row.index
                                    ? Colors.primaryForeground
                                    : Colors.surfaceForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeMd
                                font.weight: Font.Medium
                                textFormat: Text.PlainText
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: !!(row.modelData.genericName
                                    && row.modelData.genericName !== row.modelData.name)
                                text: row.modelData.genericName || ""
                                elide: Text.ElideRight
                                color: window.selectedIndex === row.index
                                    ? Tokens.withAlpha(Colors.primaryForeground, 0.75)
                                    : Colors.surfaceVariantForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: Constants.fontSizeXs
                                textFormat: Text.PlainText
                            }
                        }
                    }

                    HoverHandler {
                        id: hover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.launch(row.modelData)
                        onEntered: window.selectedIndex = row.index
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: window.filteredApps.length === 0
                    text: "No apps"
                    color: Colors.surfaceVariantForeground
                    font.family: Constants.fontFamily
                    font.pixelSize: Constants.fontSizeMd
                }
            }
        }
    }
}
