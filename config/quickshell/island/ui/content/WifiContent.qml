import Quickshell
import Quickshell.Networking
import QtQuick
import "../../config" as Config

FocusScope {
    id: root

    required property var contentModel
    required property var palette

    signal actionRequested(string action, var argument)

    readonly property real preferredWidth: Config.IslandConstants.wifiWidth
    readonly property real preferredHeight: Config.IslandConstants.wifiHeight
    readonly property var source: contentModel?.source ?? null
    readonly property var networks: source?.networks ?? []
    readonly property var selectedNetwork: sortedNetworks.values[selectedIndex] ?? null
    property int selectedIndex: 0
    property var selectionNetwork: null
    property var passwordNetwork: null
    property var pendingNetwork: null
    property string statusMessage: ""
    property bool showPassword: false
    property bool initialScanPending: true

    focus: true

    function securityLabel(network) {
        if (!network || network.security === WifiSecurityType.Open)
            return "Open"
        if (network.known)
            return "Saved"
        return "Secured"
    }

    function signalLabel(network) {
        const percent = Math.round((network?.signalStrength ?? 0) * 100)
        return percent + "%"
    }

    function moveSelection(delta) {
        const count = sortedNetworks.values.length
        if (count <= 0) {
            selectedIndex = -1
            return
        }
        selectedIndex = Math.max(0, Math.min(count - 1, selectedIndex + delta))
        selectionNetwork = sortedNetworks.values[selectedIndex]
        networkList.currentIndex = selectedIndex
        networkList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function beginPassword(network, message) {
        passwordNetwork = network
        statusMessage = message ?? ""
        passwordInput.text = ""
        showPassword = false
        passwordFocusTimer.restart()
    }

    function cancelPassword() {
        passwordInput.text = ""
        passwordNetwork = null
        statusMessage = ""
        showPassword = false
        forceActiveFocus()
    }

    function refreshNetworks() {
        initialScanPending = true
        initialScanTimer.restart()
        source?.refresh()
    }

    function activate(network) {
        if (!network || network.stateChanging)
            return
        statusMessage = ""
        if (network.connected) {
            source?.disconnect(network)
            return
        }
        if (network.known || network.security === WifiSecurityType.Open) {
            pendingNetwork = network
            source?.connect(network)
            return
        }
        if (source?.supportsPassword(network)) {
            beginPassword(network, "")
            return
        }
        statusMessage = "This network requires system authentication"
    }

    function submitPassword() {
        const network = passwordNetwork
        const password = passwordInput.text
        if (!network || !password) {
            statusMessage = "Enter the network password"
            return
        }
        pendingNetwork = network
        source?.connectWithPassword(network, password)
        cancelPassword()
    }

    function handleConnectionFailure(network, reason) {
        if (reason === ConnectionFailReason.NoSecrets && source?.supportsPassword(network)) {
            beginPassword(network, "Check the password and try again")
            return
        }
        statusMessage = source?.failureMessage(reason) ?? "Could not connect"
    }

    Component.onCompleted: {
        focusTimer.restart()
        initialScanTimer.restart()
    }

    Keys.priority: Keys.BeforeItem
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            if (root.passwordNetwork)
                root.cancelPassword()
            else
                root.actionRequested("dismiss", null)
            event.accepted = true
        } else if (!root.passwordNetwork && event.key === Qt.Key_Down) {
            root.moveSelection(1)
            event.accepted = true
        } else if (!root.passwordNetwork && event.key === Qt.Key_Up) {
            root.moveSelection(-1)
            event.accepted = true
        } else if (!root.passwordNetwork && !(root.source?.enabled ?? false)
                && (event.key === Qt.Key_Space
                    || event.key === Qt.Key_Return
                    || event.key === Qt.Key_Enter)) {
            root.source?.setEnabled(true)
            event.accepted = true
        } else if (!root.passwordNetwork
                && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)) {
            root.activate(root.selectedNetwork)
            event.accepted = true
        } else if (!root.passwordNetwork && event.key === Qt.Key_R) {
            root.refreshNetworks()
            event.accepted = true
        }
    }

    onNetworksChanged: {
        if (passwordNetwork && !networks.includes(passwordNetwork))
            cancelPassword()
    }

    Connections {
        target: root.source

        function onEnabledChanged() {
            if (!root.source?.enabled) {
                root.cancelPassword()
                root.pendingNetwork = null
                return
            }
            root.initialScanPending = true
            initialScanTimer.restart()
        }
    }

    Connections {
        target: root.pendingNetwork

        function onConnectionFailed(reason) {
            const network = root.pendingNetwork
            root.pendingNetwork = null
            root.handleConnectionFailure(network, reason)
        }

        function onConnectedChanged() {
            if (root.pendingNetwork?.connected) {
                root.pendingNetwork = null
                root.statusMessage = ""
            }
        }
    }

    ScriptModel {
        id: sortedNetworks
        values: root.networks.slice().sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1
            if (a.known !== b.known)
                return a.known ? -1 : 1
            const strengthDifference = b.signalStrength - a.signalStrength
            return strengthDifference || String(a.name).localeCompare(String(b.name))
        })

        onValuesChanged: {
            const preservedIndex = values.indexOf(root.selectionNetwork)
            root.selectedIndex = preservedIndex >= 0
                ? preservedIndex
                : values.length > 0 ? 0 : -1
            root.selectionNetwork = root.selectedIndex >= 0
                ? values[root.selectedIndex]
                : null
            networkList.currentIndex = root.selectedIndex
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: root.forceActiveFocus()
    }

    Timer {
        id: passwordFocusTimer
        interval: 50
        onTriggered: passwordInput.forceActiveFocus()
    }

    Timer {
        id: initialScanTimer
        interval: 1500
        onTriggered: root.initialScanPending = false
    }

    Item {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Config.IslandConstants.wifiPadding
            leftMargin: Config.IslandConstants.wifiPadding
            rightMargin: Config.IslandConstants.wifiPadding
        }
        height: Config.IslandConstants.wifiHeaderHeight

        Rectangle {
            id: wifiMark
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: 38
            height: 38
            radius: 12
            color: root.source?.enabled
                ? root.palette.primaryContainer
                : root.palette.surfaceContainerHigh

            Text {
                anchors.centerIn: parent
                text: Config.IslandConstants.wifiIcon
                color: root.source?.enabled
                    ? root.palette.primaryContainerForeground
                    : root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.iconFontFamily
                font.pixelSize: 17
            }
        }

        Column {
            anchors {
                left: wifiMark.right
                leftMargin: 11
                right: refreshButton.left
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 1

            Text {
                width: parent.width
                text: "Wi-Fi"
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }

            Text {
                width: parent.width
                text: {
                    if (!root.source?.hardwareEnabled) return "Disabled by hardware"
                    if (!root.source?.enabled) return "Wireless is off"
                    if (root.source?.connectedNetwork) return root.source.connectedNetwork.name
                    return "Available networks"
                }
                color: root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: refreshButton
            anchors {
                right: wifiToggle.left
                rightMargin: 9
                verticalCenter: parent.verticalCenter
            }
            width: 36
            height: 36
            radius: 11
            color: refreshMouse.containsMouse
                ? root.palette.surfaceContainerHighest
                : root.palette.surfaceContainerHigh
            opacity: root.source?.enabled ? 1 : 0.45

            Text {
                anchors.centerIn: parent
                text: Config.IslandConstants.refreshIcon
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.iconFontFamily
                font.pixelSize: 14
            }

            MouseArea {
                id: refreshMouse
                anchors.fill: parent
                enabled: root.source?.enabled ?? false
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.refreshNetworks()
            }
        }

        Rectangle {
            id: wifiToggle
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            width: 44
            height: 24
            radius: height / 2
            color: root.source?.enabled
                ? root.palette.primary
                : root.palette.surfaceContainerHighest
            opacity: root.source?.hardwareEnabled ? 1 : 0.45

            Rectangle {
                width: 18
                height: 18
                radius: width / 2
                x: root.source?.enabled ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                color: root.source?.enabled
                    ? root.palette.primaryForeground
                    : root.palette.surfaceVariantForeground
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.source?.hardwareEnabled ?? false
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.source?.setEnabled(!root.source.enabled)
            }
        }
    }

    Rectangle {
        id: statusBanner
        anchors {
            top: header.bottom
            topMargin: visible ? 6 : 0
            left: parent.left
            right: parent.right
            leftMargin: Config.IslandConstants.wifiPadding
            rightMargin: Config.IslandConstants.wifiPadding
        }
        visible: root.statusMessage.length > 0
        height: visible ? 28 : 0
        radius: 9
        color: root.palette.errorContainer

        Text {
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 10
            }
            text: root.statusMessage
            color: root.palette.errorContainerForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 11
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: passwordPanel
        anchors {
            top: statusBanner.bottom
            topMargin: visible ? 6 : 0
            left: parent.left
            right: parent.right
            leftMargin: Config.IslandConstants.wifiPadding
            rightMargin: Config.IslandConstants.wifiPadding
        }
        visible: root.passwordNetwork !== null
        height: visible ? 48 : 0
        radius: 12
        color: root.palette.surfaceContainerHigh

        TextInput {
            id: passwordInput
            anchors {
                left: parent.left
                leftMargin: 13
                right: revealPassword.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            color: root.palette.surfaceForeground
            selectionColor: root.palette.primaryContainer
            selectedTextColor: root.palette.primaryContainerForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 14
            echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            clip: true
            onAccepted: root.submitPassword()

            Keys.onEscapePressed: event => {
                root.cancelPassword()
                event.accepted = true
            }

            Text {
                anchors.fill: parent
                visible: !passwordInput.text
                text: "Password for " + (root.passwordNetwork?.name ?? "network")
                color: root.palette.surfaceVariantForeground
                font: passwordInput.font
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Text {
            id: revealPassword
            anchors {
                right: passwordSubmit.left
                rightMargin: 11
                verticalCenter: parent.verticalCenter
            }
            text: root.showPassword
                ? Config.IslandConstants.eyeSlashIcon
                : Config.IslandConstants.eyeIcon
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: 13

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onClicked: root.showPassword = !root.showPassword
            }
        }

        Rectangle {
            id: passwordSubmit
            anchors {
                right: parent.right
                rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            width: 68
            height: 36
            radius: 10
            color: root.palette.primary

            Text {
                anchors.centerIn: parent
                text: "Join"
                color: root.palette.primaryForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.submitPassword()
            }
        }
    }

    ListView {
        id: networkList
        anchors {
            top: passwordPanel.bottom
            topMargin: 8
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Config.IslandConstants.wifiPadding
            rightMargin: Config.IslandConstants.wifiPadding
            bottomMargin: Config.IslandConstants.wifiPadding
        }
        visible: root.source?.enabled ?? false
        clip: true
        model: sortedNetworks
        currentIndex: root.selectedIndex
        boundsBehavior: Flickable.StopAtBounds

        highlight: Rectangle {
            radius: 12
            color: root.palette.primaryContainer
        }
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        delegate: Item {
            id: networkRow

            required property var modelData
            required property int index

            width: networkList.width
            height: Config.IslandConstants.wifiResultHeight

            Item {
                id: strengthMark
                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                width: 24
                height: 22

                Row {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    height: parent.height
                    spacing: 2

                    Repeater {
                        model: 4

                        Rectangle {
                            required property int index
                            width: 3
                            height: 5 + index * 4
                            anchors.bottom: parent.bottom
                            radius: 2
                            color: networkRow.modelData.signalStrength >= (index + 1) * 0.2
                                ? root.palette.surfaceForeground
                                : root.palette.outlineVariant
                        }
                    }
                }
            }

            Column {
                anchors {
                    left: strengthMark.right
                    leftMargin: 11
                    right: rowStatus.left
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 1

                Text {
                    width: parent.width
                    text: networkRow.modelData.name || "Hidden network"
                    color: root.palette.surfaceForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 14
                    font.weight: networkRow.modelData.connected ? Font.DemiBold : Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.securityLabel(networkRow.modelData)
                        + " · " + root.signalLabel(networkRow.modelData)
                    color: root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            Row {
                id: rowStatus
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                spacing: 7

                Text {
                    visible: networkRow.modelData.security !== WifiSecurityType.Open
                        && !networkRow.modelData.connected
                    text: Config.IslandConstants.lockIcon
                    color: root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.iconFontFamily
                    font.pixelSize: 11
                }

                Text {
                    visible: networkRow.modelData.connected || networkRow.modelData.stateChanging
                    text: networkRow.modelData.stateChanging
                        ? (networkRow.modelData.connected ? "Disconnecting" : "Connecting")
                        : "Connected"
                    color: networkRow.modelData.connected
                        ? root.palette.primary
                        : root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: networkRow.modelData.stateChanging
                    ? Qt.ArrowCursor
                    : Qt.PointingHandCursor
                onEntered: {
                    root.selectedIndex = networkRow.index
                    root.selectionNetwork = networkRow.modelData
                    networkList.currentIndex = networkRow.index
                }
                onClicked: root.activate(networkRow.modelData)
            }

        }

        Text {
            anchors.centerIn: parent
            visible: sortedNetworks.values.length === 0
            text: root.source?.device
                ? (root.initialScanPending ? "Looking for networks…" : "No networks found · press R to rescan")
                : "No Wi-Fi adapter found"
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 12
        }
    }

    Text {
        anchors.centerIn: parent
        visible: !(root.source?.enabled ?? false)
        text: root.source?.hardwareEnabled
            ? "Press Space to turn on Wi-Fi"
            : "Wi-Fi is disabled by a hardware switch"
        color: root.palette.surfaceVariantForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: 13
    }
}
