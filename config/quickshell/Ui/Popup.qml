import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons as Commons

// Shared popup surface: one layer-shell window under the bar with a centered
// Tokyo Night card. Widgets put their content in `contentData`. This ticket
// only provides the primitive; clock calendar wiring lands with its popup.
//
// The linter reports PanelWindow as non-creatable because Quickshell's
// qmltypes describe the internal proxy; it is creatable at runtime.
// qmllint disable uncreatable-type
PanelWindow {
    id: root

    property bool open: false
    property var popupScreen: null
    property int padding: Commons.Style.spacingLg

    default property alias contentData: content.data

    screen: root.popupScreen
    visible: root.open
    color: "transparent"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    // qmllint disable unresolved-type unqualified
    margins {
        top: Commons.Style.barHeight + Commons.Style.spacingSm
    }
    // qmllint enable unresolved-type unqualified

    implicitHeight: card.height
    exclusiveZone: 0
    aboveWindows: true

    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: content.implicitWidth + root.padding * 2
        height: content.implicitHeight + root.padding * 2
        color: Commons.Color.surface
        radius: Commons.Style.widgetRadius
        border.width: 1
        border.color: Commons.Color.outline
    }

    Item {
        id: content

        anchors.top: parent.top
        anchors.topMargin: root.padding
        anchors.horizontalCenter: parent.horizontalCenter
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
// qmllint enable uncreatable-type
