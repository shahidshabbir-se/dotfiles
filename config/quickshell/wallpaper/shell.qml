import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: window
    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    focusable: true

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 0

    property bool initialFocusSet: false
    property int scrollDuration: 320
    property real scrollAccum: 0

    readonly property bool isReady: folderModel.status === FolderListModel.Ready
    readonly property real stageHeight: Math.round(Math.max(430, Math.min(560, Screen.height * 0.36)))
    readonly property real baseSlotWidth: Math.round((Screen.width - 40) / Math.max(configs.number_of_pictures || 7, 1))
    readonly property real slotWidth: Math.round(Math.max(230, baseSlotWidth + 28))
    readonly property real slotHeight: Math.round(stageHeight - 16)
    readonly property real cardWidth: Math.round(Math.max(208, slotWidth - 40))
    readonly property real cardHeight: Math.round(slotHeight - 20)
    readonly property real borderWidth: 3
    readonly property real activeScale: 1.12
    readonly property real inactiveScale: 0.72
    readonly property real inactiveOpacity: 0.58
    readonly property real inactiveYOffset: 18
    readonly property real skewFactor: -0.28
    readonly property real scrollThreshold: 240

    function clampIndex(i) {
        return Math.max(0, Math.min(i, folderModel.count - 1))
    }

    function activateCurrent() {
        if (folderModel.count === 0 || list.currentIndex < 0)
            return

        const path = folderModel.get(list.currentIndex, "filePath")
        Quickshell.execDetached(["bash", Quickshell.shellPath("commands.sh"), path])
        Qt.quit()
    }

    function initializeFocus() {
        if (initialFocusSet || folderModel.count === 0)
            return

        const targetIndex = clampIndex(list.currentIndex < 0 ? 0 : list.currentIndex)

        Qt.callLater(function() {
            list.forceLayout()
            list.currentIndex = targetIndex
            list.positionViewAtIndex(targetIndex, ListView.Center)
            list.forceActiveFocus()
            initialFocusSet = true
        })
    }

    function stepSelection(delta, duration) {
        if (folderModel.count === 0)
            return

        scrollDuration = duration
        list.currentIndex = clampIndex(list.currentIndex + delta)
        list.forceActiveFocus()
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Component.onCompleted: {
        Quickshell.execDetached(["bash", Quickshell.shellPath("cache.sh"), Quickshell.shellDir])
        Qt.callLater(function() {
            window.initializeFocus()
        })
    }

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: configs
            property string wallpaper_path
            property string cache_path
            property int number_of_pictures
            property string border_color
        }
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + configs.wallpaper_path
        nameFilters: ["*.jpg", "*.jpeg", "*.png"]
        showDirs: false
        sortField: FolderListModel.Name

        onCountChanged: {
            if (count > 0)
                window.initializeFocus()
        }

        onStatusChanged: {
            if (status === FolderListModel.Ready && count > 0)
                window.initializeFocus()
        }
    }

    Timer {
        id: scrollThrottle
        interval: 90
    }

    Item {
        id: stage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: window.stageHeight
    }

    ListView {
        id: list
        anchors.fill: stage
        anchors.margins: window.isReady ? 0 : 40
        opacity: window.isReady ? 1.0 : 0.0
        orientation: ListView.Horizontal
        spacing: 0
        clip: false
        cacheBuffer: Math.max(0, window.slotWidth * 8)
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width / 2) - (window.slotWidth / 2)
        preferredHighlightEnd: (width / 2) + (window.slotWidth / 2)
        highlightMoveDuration: window.initialFocusSet ? window.scrollDuration : 0
        focus: true
        currentIndex: 0
        model: folderModel

        Behavior on opacity {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Behavior on anchors.margins {
            NumberAnimation {
                duration: 340
                easing.type: Easing.OutExpo
            }
        }

        add: Transition {
            enabled: window.initialFocusSet

            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 280
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    property: "scale"
                    from: 0.88
                    to: 1
                    duration: 320
                    easing.type: Easing.OutBack
                }
            }
        }

        addDisplaced: Transition {
            enabled: window.initialFocusSet

            NumberAnimation {
                property: "x"
                duration: 320
                easing.type: Easing.OutCubic
            }
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                window.initialFocusSet = true
        }

        header: Item {
            width: Math.max(0, (list.width / 2) - (window.slotWidth / 2))
        }

        footer: Item {
            width: Math.max(0, (list.width / 2) - (window.slotWidth / 2))
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton

            onWheel: function(wheel) {
                if (scrollThrottle.running) {
                    wheel.accepted = true
                    return
                }

                const dx = wheel.angleDelta.x
                const dy = wheel.angleDelta.y
                const delta = Math.abs(dx) > Math.abs(dy) ? dx : dy

                if (delta === 0) {
                    wheel.accepted = true
                    return
                }

                window.scrollAccum += delta

                if (Math.abs(window.scrollAccum) >= window.scrollThreshold) {
                    window.stepSelection(window.scrollAccum > 0 ? -1 : 1, 320)
                    window.scrollAccum = 0
                    scrollThrottle.start()
                }

                wheel.accepted = true
            }
        }

        delegate: Item {
            id: delegateRoot
            readonly property bool active: ListView.isCurrentItem
            property string thumbSource: "file://" + configs.cache_path + fileName

            width: window.slotWidth
            height: window.slotHeight
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            z: active ? 10 : 1

            Item {
                id: card
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -(window.skewFactor * height) / 2
                width: window.cardWidth
                height: window.cardHeight
                scale: active ? window.activeScale : window.inactiveScale
                opacity: active ? 1.0 : window.inactiveOpacity
                y: active ? 0 : window.inactiveYOffset
                transformOrigin: Item.Center
                transform: Shear {
                    xFactor: window.skewFactor
                }

                Behavior on scale {
                    enabled: window.initialFocusSet

                    NumberAnimation {
                        duration: 340
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on opacity {
                    enabled: window.initialFocusSet

                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on y {
                    enabled: window.initialFocusSet

                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#090C11"
                }

                Image {
                    anchors.fill: parent
                    source: delegateRoot.thumbSource
                    sourceSize: Qt.size(1, 1)
                    fillMode: Image.Stretch
                    visible: true
                    asynchronous: true
                    cache: false
                    smooth: true
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: window.borderWidth
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                    }

                    Image {
                        id: img
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -48
                        width: card.width + (card.height * Math.abs(window.skewFactor)) + 50
                        height: card.height
                        fillMode: Image.PreserveAspectCrop
                        source: delegateRoot.thumbSource
                        asynchronous: true
                        cache: false
                        smooth: true

                        transform: Shear {
                            xFactor: -window.skewFactor
                        }

                        Timer {
                            id: retryTimer
                            interval: 1000
                            repeat: false

                            onTriggered: {
                                const currentSource = delegateRoot.thumbSource
                                delegateRoot.thumbSource = ""
                                delegateRoot.thumbSource = currentSource
                            }
                        }

                        onStatusChanged: {
                            if (status === Image.Error)
                                retryTimer.start()
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: active ? "transparent" : "#77000000"
                    }

                    Text {
                        visible: img.status !== Image.Ready
                        text: img.status === Image.Error ? "Caching" : "Loading..."
                        color: configs.border_color
                        anchors.centerIn: parent
                        font.pixelSize: 16

                        transform: Shear {
                            xFactor: -window.skewFactor
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onPressed: {
                        list.forceActiveFocus()
                    }

                    onClicked: {
                        list.currentIndex = index
                        window.activateCurrent()
                    }
                }
            }
        }

        Keys.onPressed: function(event) {
            const step = 1
            const big = Math.max(configs.number_of_pictures, 1)

            if (event.key === Qt.Key_J || event.key === Qt.Key_Right) {
                window.stepSelection(step, 320)

            } else if (event.key === Qt.Key_K || event.key === Qt.Key_Left) {
                window.stepSelection(-step, 320)

            } else if (event.key === Qt.Key_D || event.key === Qt.Key_PageDown) {
                window.stepSelection(big, 420)

            } else if (event.key === Qt.Key_U || event.key === Qt.Key_PageUp) {
                window.stepSelection(-big, 420)

            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                window.activateCurrent()

            } else if (event.key === Qt.Key_Escape) {
                Qt.quit()

            } else return

            event.accepted = true
        }
    }
}
