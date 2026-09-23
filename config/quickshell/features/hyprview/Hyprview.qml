import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool open: window.isActive
    property string layoutAlgorithm: "smartgrid"

    function toggle(layout: string): void {
        if (layout && layout.length > 0) root.layoutAlgorithm = layout
        window.layoutAlgorithm = root.layoutAlgorithm
        window.toggleExpose()
    }

    function close(): void {
        if (window.isActive) window.toggleExpose()
    }

    HyprviewWindow {
        id: window
        layoutAlgorithm: root.layoutAlgorithm
        liveCapture: true
        moveCursorToActiveWindow: false
    }
}
