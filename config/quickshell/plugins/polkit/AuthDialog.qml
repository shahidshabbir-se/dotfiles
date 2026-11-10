import QtQuick
import "../../Commons"

// One polkit authentication prompt. The flow is owned by the PolkitAgent;
// this component only renders it and submits or cancels the response.
FocusScope {
    id: root

    required property var flow

    readonly property bool awaiting: root.flow
        ? Boolean(root.flow.isResponseRequired) : false
    readonly property string identityName: root.flow && root.flow.selectedIdentity
        ? String(root.flow.selectedIdentity.displayName || "") : ""

    // Polkit restarts the PAM conversation after every failed attempt, so the
    // flow itself never ends on a bad password. Cap the retries here so a
    // repeated bad password finishes as a cancelled (denied) request instead
    // of leaving the caller waiting forever.
    property int failedAttempts: 0
    property int maxFailedAttempts: 3

    signal closeRequested()

    function focusPrompt() {
        passwordField.text = "";
        Qt.callLater(passwordField.forceActiveFocus);
    }

    function submit() {
        if (!root.flow || !root.flow.isResponseRequired)
            return;
        const value = passwordField.text;
        passwordField.text = "";
        root.flow.submit(value);
    }

    function cancel() {
        if (root.flow)
            root.flow.cancelAuthenticationRequest();
        root.closeRequested();
    }

    onAwaitingChanged: {
        if (!root.awaiting)
            return;
        if (root.flow && root.flow.failed) {
            root.failedAttempts += 1;
            if (root.failedAttempts >= root.maxFailedAttempts) {
                root.cancel();
                return;
            }
        }
        root.focusPrompt();
    }

    onFlowChanged: {
        root.failedAttempts = 0;
        if (root.awaiting)
            root.focusPrompt();
    }

    focus: root.awaiting
    Keys.onEscapePressed: root.cancel()

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
    }

    MouseArea {
        anchors.fill: parent
        // Clicks outside the card must not leak to the window below while
        // an authentication request is pending.
        onClicked: {}
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: Math.min(460, parent.width - 48)
        height: content.implicitHeight + 40
        radius: Style.widgetRadius
        color: Color.surface
        border.width: 1
        border.color: Color.outline

        Column {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Style.spacingXl
            spacing: Style.spacingMd

            Text {
                width: parent.width
                text: "Authentication required"
                color: Color.foregroundBright
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeLg
                font.bold: true
            }

            Text {
                width: parent.width
                visible: root.identityName.length > 0
                text: root.identityName
                color: Color.comment
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeSm
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.flow ? String(root.flow.message || "") : ""
                color: Color.foreground
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeMd
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                visible: root.flow && root.flow.supplementaryMessage
                text: root.flow ? String(root.flow.supplementaryMessage || "") : ""
                color: root.flow && root.flow.supplementaryIsError
                    ? Color.red : Color.foreground
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeSm
                wrapMode: Text.WordWrap
            }

            Text {
                width: parent.width
                visible: root.awaiting
                text: root.flow ? String(root.flow.inputPrompt || "Password") : "Password"
                color: Color.comment
                font.family: Style.fontFamily
                font.pixelSize: Style.fontSizeSm
            }

            Rectangle {
                width: parent.width
                height: 34
                visible: root.awaiting
                radius: Style.widgetRadius
                color: Color.background
                border.width: 1
                border.color: passwordField.activeFocus ? Color.blue : Color.outline

                TextInput {
                    id: passwordField

                    anchors.fill: parent
                    anchors.leftMargin: Style.spacingMd
                    anchors.rightMargin: Style.spacingMd
                    verticalAlignment: TextInput.AlignVCenter
                    color: Color.foregroundBright
                    selectionColor: Color.selection
                    selectedTextColor: Color.foregroundBright
                    font.family: Style.fontFamily
                    font.pixelSize: Style.fontSizeMd
                    echoMode: root.flow && root.flow.responseVisible
                        ? TextInput.Normal : TextInput.Password
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    onAccepted: root.submit()
                    Keys.onEscapePressed: root.cancel()
                }
            }

            Row {
                anchors.right: parent.right
                spacing: Style.spacingMd

                Rectangle {
                    width: 88
                    height: 32
                    radius: Style.widgetRadius
                    color: cancelArea.containsMouse ? Color.surfaceHigh : Color.surface
                    border.width: 1
                    border.color: Color.outline

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: Color.foreground
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeSm
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.cancel()
                    }
                }

                Rectangle {
                    width: 104
                    height: 32
                    radius: Style.widgetRadius
                    color: submitArea.containsMouse ? Color.blue : Color.selection
                    border.width: 1
                    border.color: Color.blue

                    Text {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        color: Color.foregroundBright
                        font.family: Style.fontFamily
                        font.pixelSize: Style.fontSizeSm
                    }

                    MouseArea {
                        id: submitArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.awaiting
                        onClicked: root.submit()
                    }
                }
            }
        }
    }
}
