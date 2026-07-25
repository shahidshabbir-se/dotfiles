import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration

Scope {
    id: root

    property string imagePath: ""
    readonly property int lifeMs: BarMetrics.screenshotOverlayHideMs

    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    function show(path) {
        if (!path || path.length === 0)
            return
        imagePath = path.startsWith("file://") ? path.slice(7) : path
    }

    function hide() {
        imagePath = ""
    }

    function shellQuote(path) {
        return "'" + path.replace(/'/g, "'\\''") + "'"
    }

    function basename(path) {
        const parts = path.split("/")
        return parts[parts.length - 1] ?? path
    }

    IpcHandler {
        target: "screenshot"

        function showPath(path: string): void { root.show(path) }
        function hide(): void { root.hide() }
    }

    Process {
        id: copyProcess
        running: false
        command: ["sh", "-c", "wl-copy --type image/png < " + root.shellQuote(root.imagePath)]
    }

    Process {
        id: openProcess
        running: false
        command: ["xdg-open", root.imagePath]
    }

    Process {
        id: deleteProcess
        running: false
        command: ["rm", "-f", root.imagePath]
        onExited: root.hide()
    }

    LazyLoader {
        active: root.imagePath.length > 0

        PanelWindow {
            id: overlayWindow

            screen: root.activeScreen
            visible: root.imagePath.length > 0 && root.activeScreen !== null
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "quickshell_screenshot_overlay"

            anchors.top: true
            anchors.right: true
            margins.top: BarMetrics.popupTopMargin
            margins.right: BarMetrics.popupRightMargin(root.activeScreen)

            implicitWidth: 300
            implicitHeight: card.implicitHeight + 24

            Timer {
                id: hideTimer
                interval: root.lifeMs
                repeat: false
                onTriggered: root.hide()
            }

            onVisibleChanged: {
                if (visible)
                    hideTimer.restart()
            }

            Rectangle {
                id: card
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 4
                width: parent.width - 8
                radius: 16
                color: Colors.notificationPanelBackground
                border.width: 1
                border.color: Colors.notificationPanelBorder
                implicitHeight: cardColumn.implicitHeight + 28

                opacity: 0
                transform: Translate { id: cardShift; y: -12 }

                Component.onCompleted: {
                    opacity = 1
                    cardShift.y = 0
                }
                Behavior on opacity {
                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onContainsMouseChanged: {
                        if (containsMouse)
                            hideTimer.stop()
                        else if (root.imagePath.length > 0)
                            hideTimer.restart()
                    }
                }

                ColumnLayout {
                    id: cardColumn
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: Colors.workspaceActive
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: "Screenshot captured"
                                color: Colors.textPrimary
                                font.family: "Outfit"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.imagePath.length > 0 ? root.basename(root.imagePath) : ""
                                color: Colors.textMuted
                                font.family: "Outfit"
                                font.pixelSize: 10
                                elide: Text.ElideMiddle
                            }
                        }

                        IconButton {
                            glyph: "󰅖"
                            tone: "neutral"
                            diameter: 26
                            glyphSize: 13
                            onActivated: root.hide()
                        }
                    }

                    Rectangle {
                        id: thumbFrame
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        radius: 12
                        color: Colors.moduleBackground
                        border.width: 1
                        border.color: Colors.moduleBorder
                        clip: true

                        Image {
                            id: previewImage
                            anchors.fill: parent
                            anchors.margins: 1
                            source: root.imagePath.length > 0 ? "file://" + root.imagePath : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            mipmap: true
                            layer.enabled: true
                            layer.smooth: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: previewImage.width
                                    height: previewImage.height
                                    radius: 11
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: openProcess.running = true

                            Rectangle {
                                anchors.fill: parent
                                radius: 11
                                color: Colors.workspaceActive
                                opacity: parent.containsMouse ? 0.12 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: 140 }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ActionPill {
                            Layout.fillWidth: true
                            glyph: "󰆏"
                            label: "Copy"
                            onActivated: {
                                copyProcess.running = true
                                root.hide()
                            }
                        }

                        ActionPill {
                            Layout.fillWidth: true
                            glyph: "󰈈"
                            label: "Open"
                            onActivated: openProcess.running = true
                        }

                        IconButton {
                            glyph: "󰩹"
                            tone: "danger"
                            diameter: 34
                            glyphSize: 15
                            onActivated: deleteProcess.running = true
                        }
                    }
                }
            }
        }
    }

    component ActionPill: Rectangle {
        id: pill

        property string glyph
        property string label
        signal activated()

        implicitHeight: 34
        radius: 10
        color: pillHover.hovered ? Colors.moduleBackgroundHover : Colors.moduleBackground
        border.width: 1
        border.color: pillHover.hovered ? Colors.moduleBorderHover : Colors.moduleBorder

        RowLayout {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: pill.glyph
                color: pillHover.hovered ? Colors.workspaceActive : Colors.textPrimary
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 14
            }

            Text {
                text: pill.label
                color: Colors.textPrimary
                font.family: "Outfit"
                font.pixelSize: 12
            }
        }

        HoverHandler { id: pillHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.activated()
        }
    }

    component IconButton: Rectangle {
        id: iconBtn

        property string glyph
        property string tone: "neutral"
        property int diameter: 32
        property int glyphSize: 14
        signal activated()

        readonly property bool danger: tone === "danger"

        implicitWidth: diameter
        implicitHeight: diameter
        radius: diameter / 2
        color: iconHover.hovered
            ? (danger ? Colors.withAlpha(Colors.batteryLow, 0.2) : Colors.moduleBackgroundHover)
            : Colors.moduleBackground
        border.width: 1
        border.color: iconHover.hovered
            ? (danger ? Colors.withAlpha(Colors.batteryLow, 0.6) : Colors.moduleBorderHover)
            : Colors.moduleBorder

        Text {
            anchors.centerIn: parent
            text: iconBtn.glyph
            color: iconHover.hovered
                ? (iconBtn.danger ? Colors.batteryLow : Colors.workspaceActive)
                : Colors.textSecondary
            font.family: "Symbols Nerd Font Mono"
            font.pixelSize: iconBtn.glyphSize
        }

        HoverHandler { id: iconHover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: iconBtn.activated()
        }
    }
}
