pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.shared.theme

PanelWindow {
    id: root

    required property var historyModel
    property bool open: false
    property int historyCount: 0
    // Defaults match Bar LayerPopup (8px under bar via spacingMd).
    property int topOffset: Constants.barTopMargin + Constants.barHeight + Constants.spacingMd
    property int rightOffset: Constants.spacingMd
    property bool doNotDisturb: false
    property bool presented: false
    property double now: Date.now()

    signal closeRequested()
    signal clearRequested()
    signal doNotDisturbToggled()

    readonly property int screenMargin: screen && screen.width < 448 ? 8 : 12
    // Available width from bar-aligned right edge (same as network/music).
    readonly property int availableWidth: screen
        ? Math.max(1, screen.width - rightOffset - screenMargin)
        : NotificationMetrics.railWidth + NotificationMetrics.windowGutter * 2
    // Flush right edge like network/music — no side gutter padding.
    readonly property int panelWidth: Math.min(
        NotificationMetrics.railWidth,
        Math.max(1, availableWidth)
    )

    // Max height under the bar; actual card is content-sized (not a tall empty shell).
    readonly property int maxPanelHeight: screen
        ? Math.max(1, Math.min(
            NotificationMetrics.centerMaxHeight,
            screen.height - topOffset - screenMargin
        ))
        : NotificationMetrics.centerMaxHeight

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    visible: presented
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: open
    surfaceFormat.opaque: false

    WlrLayershell.namespace: "quickshell-notification-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    // While open: whole screen is hit-testable (outside click closes).
    // While closing/closed: empty mask so apps under the fade stay usable.
    mask: Region {
        width: root.open ? (root.screen ? root.screen.width : 1) : 0
        height: root.open ? (root.screen ? root.screen.height : 1) : 0
    }

    onOpenChanged: {
        if (open) {
            closeAnimation.stop()

            if (!presented) {
                surface.visualOpacity = 0
                surface.visualScale = 0.965
                surface.horizontalOffset = 14
                surface.verticalOffset = -8
                presented = true
            }

            Qt.callLater(() => {
                openAnimation.restart()
                keyCatcher.forceActiveFocus()
            })
            now = Date.now()
        } else if (presented) {
            openAnimation.stop()
            closeAnimation.restart()
        }
    }

    Component.onCompleted: {
        if (open) {
            presented = true
            Qt.callLater(() => openAnimation.restart())
        }
    }

    Timer {
        interval: 60000
        running: root.presented
        repeat: true
        onTriggered: root.now = Date.now()
    }

    // Outside click / Escape dismiss.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        enabled: root.open
        onClicked: root.closeRequested()
    }

    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: root.closeRequested()
    }

    Item {
        id: panelHost

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.topOffset
        // Align right edge with floating bar (same as network/music).
        anchors.rightMargin: root.rightOffset
        width: root.panelWidth
        // Follow content so we don't leave a tall empty rounded shell.
        height: surface.height

        // Swallow so card clicks don't hit the dismiss MouseArea.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            z: -1
        }
    }

    Rectangle {
        id: surface
        parent: panelHost

        property real visualOpacity: 0
        property real visualScale: 0.965
        property real horizontalOffset: 14
        property real verticalOffset: -8

        width: root.panelWidth
        // Header 82 + DND 62 + list area (content-sized, capped).
        height: Math.min(
            root.maxPanelHeight,
            82 + 62 + listArea.preferredHeight
        )
        radius: NotificationMetrics.surfaceRadius
        color: Colors.surfaceContainerLow
        opacity: visualOpacity
        clip: true
        border.width: Constants.borderWidth
        border.color: Colors.surfaceContainerHighest

        transform: [
            Scale {
                origin.x: surface.width
                origin.y: 0
                xScale: surface.visualScale
                yScale: surface.visualScale
            },
            Translate {
                x: surface.horizontalOffset
                y: surface.verticalOffset
            }
        ]

        // Soft drop under the card only (not a second floating rounded layer).
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 2
            anchors.rightMargin: -2
            radius: parent.radius
            color: Qt.rgba(Colors.shadow.r, Colors.shadow.g, Colors.shadow.b, 0.28)
            z: -1
            opacity: surface.visualOpacity
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 82

                Column {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 20
                    }
                    spacing: 3

                    Row {
                        spacing: Constants.spacingMd

                        Text {
                            text: "Notifications"
                            color: Colors.surfaceForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: root.panelWidth < 340 ? 18 : 20
                            font.weight: Font.DemiBold
                            font.letterSpacing: -0.3
                            textFormat: Text.PlainText
                        }

                        Rectangle {
                            visible: root.historyCount > 0 && root.panelWidth >= 360
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(22, countLabel.implicitWidth + 10)
                            height: 20
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.06)

                            Text {
                                id: countLabel

                                anchors.centerIn: parent
                                text: root.historyCount
                                color: Colors.surfaceVariantForeground
                                font.family: Constants.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                textFormat: Text.PlainText
                            }
                        }
                    }

                    Text {
                        text: Qt.formatDate(new Date(root.now), "dddd, MMMM d")
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        textFormat: Text.PlainText
                    }
                }

                Row {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 16
                    }
                    spacing: Constants.spacingSm

                    Rectangle {
                        visible: root.historyCount > 0
                        width: clearLabel.implicitWidth + 18
                        height: 30
                        radius: NotificationMetrics.controlRadius
                        color: clearArea.containsMouse
                            ? Qt.rgba(Colors.error.r, Colors.error.g, Colors.error.b, 0.11)
                            : "transparent"
                        scale: clearArea.pressed ? 0.97 : 1

                        Behavior on color {
                            ColorAnimation { duration: Constants.animationFast }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Constants.animationFast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: clearLabel

                            anchors.centerIn: parent
                            text: root.panelWidth < 340 ? "Clear" : "Clear all"
                            color: clearArea.containsMouse
                                ? Colors.error
                                : Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            textFormat: Text.PlainText

                            Behavior on color {
                                ColorAnimation { duration: Constants.animationFast }
                            }
                        }

                        MouseArea {
                            id: clearArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.clearRequested()
                        }
                    }

                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: closeArea.containsMouse
                            ? Qt.rgba(1, 1, 1, 0.09)
                            : Qt.rgba(1, 1, 1, 0.045)
                        scale: closeArea.pressed ? 0.92 : 1

                        Behavior on color {
                            ColorAnimation { duration: Constants.animationFast }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Constants.animationFast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: "×"
                            color: Colors.surfaceVariantForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            textFormat: Text.PlainText
                        }

                        MouseArea {
                            id: closeArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.closeRequested()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 62

                Rectangle {
                    id: doNotDisturbControl

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                        topMargin: 6
                        bottomMargin: 6
                    }
                    radius: NotificationMetrics.historyRadius
                    color: root.doNotDisturb
                        ? Qt.rgba(
                            Colors.primary.r,
                            Colors.primary.g,
                            Colors.primary.b,
                            0.11
                        )
                        : dndArea.containsMouse
                            ? Qt.rgba(1, 1, 1, 0.055)
                            : Qt.rgba(1, 1, 1, 0.032)
                    scale: dndArea.pressed ? 0.99 : 1

                    Behavior on color {
                        ColorAnimation { duration: Constants.animationFast }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Constants.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 12
                        }
                        width: 32
                        height: 32
                        radius: 11
                        color: root.doNotDisturb
                            ? Qt.rgba(
                                Colors.primary.r,
                                Colors.primary.g,
                                Colors.primary.b,
                                0.16
                            )
                            : Qt.rgba(1, 1, 1, 0.05)

                        Text {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -1
                            text: "☾"
                            color: root.doNotDisturb
                                ? Colors.primary
                                : Colors.surfaceVariantForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: 19
                            font.weight: Font.Medium
                            textFormat: Text.PlainText
                        }
                    }

                    Column {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 56
                        }
                        spacing: 1

                        Text {
                            text: "Do Not Disturb"
                            color: Colors.surfaceForeground
                            font.family: Constants.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            textFormat: Text.PlainText
                        }

                        Text {
                            text: root.doNotDisturb
                                ? "Only critical alerts will appear"
                                : "Silence notification banners"
                            color: Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: 11
                            textFormat: Text.PlainText
                        }
                    }

                    Rectangle {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 12
                        }
                        width: 38
                        height: 22
                        radius: 11
                        color: root.doNotDisturb
                            ? Colors.primary
                            : Colors.surfaceContainerHighest

                        Behavior on color {
                            ColorAnimation { duration: Constants.animationFast }
                        }

                        Rectangle {
                            y: 3
                            x: root.doNotDisturb ? parent.width - width - 3 : 3
                            width: 16
                            height: 16
                            radius: 8
                            color: root.doNotDisturb
                                ? Colors.primaryForeground
                                : Colors.surfaceVariantForeground

                            Behavior on x {
                                NumberAnimation {
                                    duration: Constants.animationNormal
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 0.12
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: dndArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doNotDisturbToggled()
                    }
                }
            }

            Item {
                id: listArea
                Layout.fillWidth: true
                // Grow with list content; cap so surface.height stays under maxPanelHeight.
                readonly property int preferredHeight: root.historyCount > 0
                    ? Math.min(
                        root.maxPanelHeight - 82 - 62,
                        Math.max(120, historyList.contentHeight + 10)
                    )
                    : 160
                Layout.preferredHeight: preferredHeight

                ListView {
                    id: historyList

                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 10
                        bottomMargin: 10
                    }
                    visible: root.historyCount > 0
                    clip: true
                    spacing: 1
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.historyModel

                    header: Item {
                        width: historyList.width
                        height: 40

                        Text {
                            anchors {
                                left: parent.left
                                bottom: parent.bottom
                                leftMargin: Constants.paddingMd
                                bottomMargin: Constants.spacingMd
                            }
                            text: "Recent"
                            color: Colors.outline
                            font.family: Constants.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.25
                            textFormat: Text.PlainText
                        }
                    }

                    delegate: NotificationHistoryItem {
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        entry: modelData
                        now: root.now
                        lastItem: index === root.historyCount - 1
                    }

                    displaced: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: NotificationMetrics.stackDuration
                            easing.type: Easing.InOutCubic
                        }
                    }
                }

                Column {
                    anchors.centerIn: parent
                    visible: root.historyCount === 0
                    spacing: Constants.spacingMd

                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 42
                        height: 42

                        Rectangle {
                            anchors.centerIn: parent
                            width: 30
                            height: 30
                            radius: 15
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(
                                Colors.primary.r,
                                Colors.primary.g,
                                Colors.primary.b,
                                0.34
                            )
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6
                            height: 6
                            radius: 3
                            color: Colors.primary
                            opacity: 0.72
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        color: Colors.surfaceForeground
                        font.family: Constants.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        textFormat: Text.PlainText
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "You’re all caught up."
                        color: Colors.outline
                        font.family: Constants.fontFamily
                        font.pixelSize: 12
                        textFormat: Text.PlainText
                    }
                }
            }
        }
    }

    ParallelAnimation {
        id: openAnimation

        NumberAnimation {
            target: surface
            property: "visualOpacity"
            to: 1
            duration: 170
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "visualScale"
            to: 1
            duration: NotificationMetrics.centerEnterDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "horizontalOffset"
            to: 0
            duration: NotificationMetrics.centerEnterDuration
            easing.type: Easing.OutExpo
        }

        NumberAnimation {
            target: surface
            property: "verticalOffset"
            to: 0
            duration: NotificationMetrics.centerEnterDuration
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation

        NumberAnimation {
            target: surface
            property: "visualOpacity"
            to: 0
            duration: 110
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "visualScale"
            to: 0.98
            duration: NotificationMetrics.centerExitDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "horizontalOffset"
            to: 10
            duration: NotificationMetrics.centerExitDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: surface
            property: "verticalOffset"
            to: -6
            duration: NotificationMetrics.centerExitDuration
            easing.type: Easing.OutCubic
        }

        onFinished: {
            if (!root.open)
                root.presented = false
        }
    }
}
