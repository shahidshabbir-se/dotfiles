import Quickshell
import QtQuick
import "../config" as Config

Scope {
    id: root

    property string kind: "clock"
    property var model: ({ text: Qt.formatDateTime(new Date(), Config.IslandConstants.timeFormat) })
    property bool expanded: false
    property var sourceHandle: null
    property int revision: 0
    property string clockText: Qt.formatDateTime(new Date(), Config.IslandConstants.timeFormat)
    property bool keyboardReveal: false
    property bool edgeReveal: false
    property bool pointerInside: false
    readonly property bool revealed: kind !== "clock" || keyboardReveal || edgeReveal

    signal sourceHandleReleased(var handle)
    signal presentationDismissed(string kind)

    function setKeyboardReveal(value) {
        keyboardReveal = value
    }

    function setEdgeReveal(value) {
        edgeHideTimer.stop()
        if (value) {
            edgeReveal = true
            return
        }
        edgeHideTimer.restart()
    }

    function setPointerInside(value) {
        if (pointerInside === value)
            return

        pointerInside = value
        if (pointerInside) {
            expiryTimer.stop()
            return
        }

        const ttl = ttlFor(kind)
        if (ttl > 0 && !expanded) {
            expiryTimer.interval = ttl
            expiryTimer.armedRevision = revision
            expiryTimer.restart()
        }
    }

    function priorityFor(candidateKind) {
        switch (candidateKind) {
        case "workspace": return Config.IslandConstants.workspacePriority
        case "media":
        case "notification": return Config.IslandConstants.passivePriority
        case "wifi":
        case "clipboard":
        case "launcher":
        case "menu": return Config.IslandConstants.interactivePriority
        default: return 0
        }
    }

    function ttlFor(candidateKind) {
        switch (candidateKind) {
        case "workspace": return Config.IslandConstants.workspaceTtl
        case "media":
        case "notification": return Config.IslandConstants.popupTtl
        default: return 0
        }
    }

    function release(handle) {
        if (handle !== null && handle !== undefined)
            sourceHandleReleased(handle)
    }

    function present(candidateKind, candidateModel, candidateHandle) {
        if (priorityFor(candidateKind) < priorityFor(kind)) {
            release(candidateHandle)
            return false
        }

        expiryTimer.stop()
        if (sourceHandle !== candidateHandle)
            release(sourceHandle)

        revision += 1
        kind = candidateKind
        model = candidateModel
        expanded = false
        sourceHandle = candidateHandle

        const ttl = ttlFor(candidateKind)
        if (ttl > 0 && !pointerInside) {
            expiryTimer.interval = ttl
            expiryTimer.armedRevision = revision
            expiryTimer.start()
        }
        return true
    }

    function updateModel(candidateKind, candidateModel) {
        if (kind !== candidateKind)
            return false
        model = candidateModel
        return true
    }

    function setExpanded(value) {
        if (kind !== "notification" || expanded === value)
            return

        expanded = value
        expiryTimer.stop()
        if (!expanded && !pointerInside) {
            expiryTimer.interval = ttlFor(kind)
            expiryTimer.armedRevision = revision
            expiryTimer.start()
        }
    }

    function dismiss() {
        const dismissedKind = kind
        const dismissedHandle = sourceHandle
        expiryTimer.stop()
        revision += 1
        kind = "clock"
        model = ({ text: clockText })
        expanded = false
        sourceHandle = null
        release(dismissedHandle)
        presentationDismissed(dismissedKind)
    }

    function expire(expectedRevision) {
        if (expectedRevision !== revision)
            return
        dismiss()
    }

    Timer {
        interval: Config.IslandConstants.clockRefreshInterval
        running: true
        repeat: true
        onTriggered: {
            root.clockText = Qt.formatDateTime(new Date(), Config.IslandConstants.timeFormat)
            if (root.kind === "clock")
                root.model = ({ text: root.clockText })
        }
    }

    Timer {
        id: expiryTimer
        property int armedRevision: -1
        onTriggered: root.expire(armedRevision)
    }

    Timer {
        id: edgeHideTimer
        interval: Config.IslandConstants.edgeRevealHideDelay
        onTriggered: root.edgeReveal = false
    }
}
