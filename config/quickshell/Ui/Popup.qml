import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons as Commons

// Shared popup surface: one layer-shell window under the bar with a centered
// Tokyo Night card. Widgets put their content in `contentData`.
//
// `modal: true` makes the window cover the screen, so an outside click can
// dismiss the popup and Escape works while it has keyboard focus. Widgets that
// set `modal` should handle `dismissed`.
//
// The linter reports PanelWindow as non-creatable because Quickshell's
// qmltypes describe the internal proxy; it is creatable at runtime.
// qmllint disable uncreatable-type
PanelWindow {
    id: root

    property bool open: false
    property var popupScreen: null
    property int padding: Commons.Style.spacingLg
    property bool modal: false

    signal dismissed()

    readonly property int cardTopMargin: root.modal
        ? Commons.Style.barHeight + Commons.Style.spacingSm
        : 0

    default property alias contentData: content.data

    screen: root.popupScreen
    visible: root.open
    color: "transparent"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: root.modal
    // qmllint disable unresolved-type unqualified
    margins {
        top: root.modal ? 0 : root.cardTopMargin
    }
    // qmllint enable unresolved-type unqualified

    implicitHeight: root.modal
        ? (root.popupScreen ? root.popupScreen.height : 1)
        : card.height
    exclusiveZone: 0
    aboveWindows: true
    focusable: root.modal && root.open

    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.modal && root.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    MouseArea {
        id: backdrop

        anchors.fill: parent
        visible: root.modal
        enabled: root.modal && root.open
        focus: root.modal && root.open
        cursorShape: Qt.ArrowCursor
        onClicked: root.dismissed()

        Keys.onEscapePressed: event => {
            root.dismissed();
            event.accepted = true;
        }
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.topMargin: root.cardTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        width: content.implicitWidth + root.padding * 2
        height: content.implicitHeight + root.padding * 2
        color: Commons.Color.surface
        radius: Commons.Style.widgetRadius
        border.width: 1
        border.color: Commons.Color.outline

        // Clicks on the card itself must not reach the backdrop.
        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        id: content

        anchors.top: card.top
        anchors.topMargin: root.padding
        anchors.horizontalCenter: card.horizontalCenter
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
// qmllint enable uncreatable-type
