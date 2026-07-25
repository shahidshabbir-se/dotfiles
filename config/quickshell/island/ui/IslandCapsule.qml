import QtQuick
import Qt5Compat.GraphicalEffects
import "content"
import "../config" as Config

Rectangle {
    id: root

    required property var controller
    required property var palette
    property real maximumWidth: Config.IslandConstants.capsuleMaximumWidth
    property bool revealed: true

    signal expandedRequested(bool value)
    signal actionRequested(string action, var argument)
    signal hoverChanged(bool hovered)

    readonly property real desiredWidth: {
        if (controller.kind === "clock" || controller.kind === "workspace")
            return Math.max(contentLoader.item?.preferredWidth ?? 0, workspaceReserve.advanceWidth)
                + Config.IslandConstants.clockHorizontalPadding * 2
        return contentLoader.item?.preferredWidth ?? Config.IslandConstants.notificationMinimumWidth
    }
    readonly property real desiredHeight: contentLoader.item?.preferredHeight
        ?? Config.IslandConstants.clockHeight

    width: Math.min(maximumWidth, desiredWidth)
    height: desiredHeight
    radius: height <= Config.IslandConstants.capsuleCompactHeightLimit
        ? height / 2
        : Config.IslandConstants.capsuleLargeRadius
    clip: true
    opacity: revealed ? 1 : 0
    color: Qt.rgba(
        palette.surfaceContainerHigh.r,
        palette.surfaceContainerHigh.g,
        palette.surfaceContainerHigh.b,
        Config.IslandConstants.capsuleBackgroundOpacity
    )
    layer.enabled: true
    layer.smooth: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    Behavior on width {
        NumberAnimation { duration: Config.IslandConstants.capsuleMorphDuration; easing.type: Easing.OutQuint }
    }
    Behavior on height {
        NumberAnimation { duration: Config.IslandConstants.capsuleMorphDuration; easing.type: Easing.OutQuint }
    }
    Behavior on radius {
        NumberAnimation { duration: Config.IslandConstants.capsuleMorphDuration; easing.type: Easing.OutQuint }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: Config.IslandConstants.capsuleRevealDuration
            easing.type: Easing.OutCubic
        }
    }

    transform: Translate {
        y: root.revealed
            ? 0
            : -root.height - Config.IslandConstants.windowTopMargin

        Behavior on y {
            NumberAnimation {
                duration: Config.IslandConstants.capsuleRevealDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
        sourceComponent: {
            switch (root.controller.kind) {
            case "workspace": return workspaceComponent
            case "notification": return notificationComponent
            case "media": return mediaComponent
            case "launcher": return launcherComponent
            case "clipboard": return clipboardComponent
            default: return clockComponent
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.controller.kind === "clock" && root.controller.mediaAvailable
        visible: enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.actionRequested("openMedia", null)
    }

    HoverHandler {
        cursorShape: root.controller.kind === "clock" && root.controller.mediaAvailable
            ? Qt.PointingHandCursor
            : Qt.ArrowCursor
        onHoveredChanged: root.hoverChanged(hovered)
    }

    TextMetrics {
        id: workspaceReserve
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: Config.IslandConstants.clockFontSize
        font.weight: Font.Medium
        text: Config.IslandConstants.workspaceReserveText
    }

    Component {
        id: clockComponent
        ClockContent {
            contentModel: root.controller.model
            palette: root.palette
        }
    }

    Component {
        id: workspaceComponent
        WorkspaceContent {
            contentModel: root.controller.model
            palette: root.palette
        }
    }

    Component {
        id: notificationComponent
        NotificationContent {
            contentModel: root.controller.model
            palette: root.palette
            expanded: root.controller.expanded
            onExpandedRequested: value => root.expandedRequested(value)
            onActionRequested: action => root.actionRequested(action, null)
        }
    }

    Component {
        id: mediaComponent
        MediaContent {
            contentModel: root.controller.model
            palette: root.palette
            onActionRequested: (action, argument) => root.actionRequested(action, argument)
        }
    }

    Component {
        id: launcherComponent
        LauncherContent {
            contentModel: root.controller.model
            palette: root.palette
            onActionRequested: (action, argument) => root.actionRequested(action, argument)
        }
    }

    Component {
        id: clipboardComponent
        ClipboardContent {
            contentModel: root.controller.model
            palette: root.palette
            onActionRequested: (action, argument) => root.actionRequested(action, argument)
        }
    }
}
