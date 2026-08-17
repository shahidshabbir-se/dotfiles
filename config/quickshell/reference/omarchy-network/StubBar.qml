import QtQuick
import Quickshell
import qs.Commons

// Minimal stand-in for Omarchy's bar host. Only the surface the network
// panel / KeyboardPanel / WidgetButton actually touch.
PanelWindow {
    id: bar

    property string position: "top"
    property bool vertical: false
    property int barSize: Style.bar.sizeHorizontal
    property color foreground: Color.foreground
    property color barForeground: Color.foreground
    property color background: Color.bar.background
    property color urgent: Color.urgent
    property string fontFamily: Style.font.family
    property bool foregroundAnimationEnabled: false
    property var activePopout: null
    property var clickTargets: []
    property var shell: QtObject {
        function summon(id, payload) {
            console.log("[preview] shell.summon", id, payload)
        }
        function hide(id) {
            console.log("[preview] shell.hide", id)
        }
    }

    function requestPopout(key) { activePopout = key }
    function releasePopout(key) { if (activePopout === key) activePopout = null }
    function registerClickTarget(item) {
        if (clickTargets.indexOf(item) < 0) {
            var next = clickTargets.slice()
            next.push(item)
            clickTargets = next
        }
    }
    function unregisterClickTarget(item) {
        var next = clickTargets.filter(function(t) { return t !== item })
        clickTargets = next
    }
    function targetBelongsToWindow(target, window) { return true }
    function hideTooltip(item) {}
    function showTooltip(item, text) {}
    function switchPanelFrom(panel, direction) { return false }
    function moduleWidgets(name) { return [] }
    function run(cmd) {
        console.log("[preview] bar.run", cmd)
        Quickshell.execDetached(["bash", "-lc", cmd])
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: barSize + 8
    exclusiveZone: implicitHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Color.bar.background
        border.color: Color.accent
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8

            // Network widget slot (filled by shell.qml child)
            Item {
                id: networkSlot
                width: Style.bar.iconSlot
                height: parent.height
                // NetworkPanel anchors.fill parent of this via default child — see shell.qml
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "omarchy network preview — click icon / Esc"
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.body
            }
        }
    }

    // Host children (NetworkPanel) inside the icon slot area on the left.
    default property alias content: host.data
    Item {
        id: host
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 4
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        width: Style.bar.iconSlot
    }
}
