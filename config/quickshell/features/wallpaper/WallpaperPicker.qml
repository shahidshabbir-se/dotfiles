import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import qs.shared.theme

PanelWindow {
    id: window

    property bool open: false
    signal closeRequested()

    implicitWidth: Screen.width
    implicitHeight: Screen.height
    color: "transparent"
    focusable: true
    visible: open

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    aboveWindows: true
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    property bool initialFocusSet: false
    property bool activeQueryDone: false
    property string activeWallpaperPath: ""
    property string searchQuery: ""
    property int scrollDuration: 320
    property real scrollAccum: 0

    readonly property string featureDir: Quickshell.shellPath("features/wallpaper")
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
    readonly property real inactiveYOffset: 18
    readonly property real skewFactor: -0.28
    readonly property real scrollThreshold: 240
    readonly property real searchBarWidth: Math.min(420, Screen.width - 48)

    function clampIndex(i) {
        return Math.max(0, Math.min(i, filteredModel.count - 1))
    }

    function basename(path) {
        const parts = String(path || "").split("/")
        return parts.length ? parts[parts.length - 1] : ""
    }

    function rebuildFiltered() {
        const query = String(searchQuery || "").trim().toLowerCase()
        filteredModel.clear()

        for (let i = 0; i < folderModel.count; i++) {
            const fileName = String(folderModel.get(i, "fileName") || "")
            const filePath = String(folderModel.get(i, "filePath") || "")
            if (query.length > 0 && fileName.toLowerCase().indexOf(query) < 0)
                continue

            filteredModel.append({
                fileName: fileName,
                filePath: filePath
            })
        }

        if (!open)
            return

        if (filteredModel.count === 0) {
            list.currentIndex = -1
            return
        }

        const preferred = query.length === 0 ? findActiveIndex() : 0
        const targetIndex = clampIndex(preferred)
        Qt.callLater(function() {
            list.forceLayout()
            list.currentIndex = targetIndex
            list.positionViewAtIndex(targetIndex, ListView.Center)
        })
    }

    function findActiveIndex() {
        if (filteredModel.count === 0)
            return 0

        const active = String(activeWallpaperPath || "")
        if (active.length === 0)
            return 0

        const activeName = basename(active)
        for (let i = 0; i < filteredModel.count; i++) {
            const path = String(filteredModel.get(i).filePath || "")
            if (path === active || basename(path) === activeName)
                return i
        }

        return 0
    }

    function activateCurrent() {
        if (filteredModel.count === 0 || list.currentIndex < 0)
            return

        const path = filteredModel.get(list.currentIndex).filePath
        Quickshell.execDetached(["bash", featureDir + "/scripts/commands.sh", path])
        window.closeRequested()
    }

    function initializeFocus() {
        if (!open || initialFocusSet || !activeQueryDone || !isReady)
            return

        rebuildFiltered()

        if (filteredModel.count === 0) {
            list.forceActiveFocus()
            initialFocusSet = true
            return
        }

        const targetIndex = clampIndex(findActiveIndex())

        Qt.callLater(function() {
            list.forceLayout()
            list.currentIndex = targetIndex
            list.positionViewAtIndex(targetIndex, ListView.Center)
            list.forceActiveFocus()
            initialFocusSet = true
        })
    }

    function stepSelection(delta, duration) {
        if (filteredModel.count === 0)
            return

        // Let StrictlyEnforceRange + highlightMoveDuration animate the slide.
        // positionViewAtIndex jumps and kills that animation.
        scrollDuration = duration
        list.currentIndex = clampIndex(list.currentIndex + delta)
    }

    function warmCache() {
        Quickshell.execDetached(["bash", featureDir + "/scripts/cache.sh", featureDir])
    }

    function queryActiveWallpaper() {
        activeQueryDone = false
        activeWallpaperPath = ""
        if (activeQuery.running)
            activeQuery.running = false
        activeQuery.running = true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-wallpaper"

    onOpenChanged: {
        if (open) {
            initialFocusSet = false
            scrollAccum = 0
            searchQuery = ""
            searchField.text = ""
            warmCache()
            queryActiveWallpaper()
        }
    }

    onSearchQueryChanged: rebuildFiltered()

    Component.onCompleted: {
        if (open) {
            warmCache()
            queryActiveWallpaper()
        }
    }

    Process {
        id: activeQuery
        command: ["awww", "query"]

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const match = String(text || "").match(/currently displaying: image:\s*(.+)/)
                window.activeWallpaperPath = match ? String(match[1]).trim() : ""
                window.activeQueryDone = true
                window.initializeFocus()
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (window.activeQueryDone)
                return
            window.activeQueryDone = true
            window.initializeFocus()
        }
    }

    FileView {
        path: featureDir + "/config.json"
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
        folder: configs.wallpaper_path ? "file://" + configs.wallpaper_path : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png"]
        showDirs: false
        sortField: FolderListModel.Name

        onCountChanged: {
            if (window.initialFocusSet)
                window.rebuildFiltered()
            else if (count > 0)
                window.initializeFocus()
        }

        onStatusChanged: {
            if (status === FolderListModel.Ready)
                window.initializeFocus()
        }
    }

    ListModel {
        id: filteredModel
    }

    Timer {
        id: scrollThrottle
        interval: 90
    }

    Rectangle {
        id: searchBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: stage.top
        anchors.bottomMargin: Constants.spacingXl
        width: window.searchBarWidth
        height: Constants.buttonSize + Constants.paddingMd
        radius: Constants.buttonRadius
        color: Colors.surfaceContainerLow
        border.width: Constants.borderWidth
        border.color: searchField.activeFocus
            ? Colors.primary
            : Colors.surfaceContainerHighest
        opacity: window.open ? 1 : 0
        z: 20

        Behavior on opacity {
            NumberAnimation {
                duration: Constants.animationNormal
                easing.type: Easing.OutCubic
            }
        }

        TextField {
            id: searchField
            anchors.fill: parent
            anchors.leftMargin: Constants.paddingMd
            anchors.rightMargin: Constants.paddingMd
            verticalAlignment: TextInput.AlignVCenter
            placeholderText: "Search wallpapers"
            placeholderTextColor: Colors.outline
            color: Colors.surfaceForeground
            font.family: Constants.fontFamily
            font.pixelSize: Constants.fontSizeMd
            background: Item {}
            selectByMouse: true

            onTextChanged: window.searchQuery = text

            // Search focused: left/right = caret. PgUp/PgDn = one wallpaper step.
            // Down hands focus to list so arrows can nav without fighting caret.
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_PageUp) {
                    window.stepSelection(-1, 320)
                    event.accepted = true
                } else if (event.key === Qt.Key_PageDown) {
                    window.stepSelection(1, 320)
                    event.accepted = true
                } else if (event.key === Qt.Key_Down) {
                    list.forceActiveFocus()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    window.activateCurrent()
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    if (text.length > 0)
                        text = ""
                    list.forceActiveFocus()
                    event.accepted = true
                }
            }
        }
    }

    Item {
        id: stage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: window.stageHeight
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: stage.verticalCenter
        visible: window.open && window.isReady && filteredModel.count === 0
        text: window.searchQuery.length > 0 ? "No matches" : "No wallpapers"
        color: Colors.outline
        font.family: Constants.fontFamily
        font.pixelSize: Constants.fontSizeLg
        z: 10
    }

    ListView {
        id: list
        anchors.fill: stage
        anchors.margins: window.isReady ? 0 : 40
        opacity: window.isReady && window.open ? 1.0 : 0.0
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
        model: filteredModel

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
            required property int index
            required property string fileName
            required property string filePath
            readonly property bool active: ListView.isCurrentItem
            property string thumbSource: "file://" + configs.cache_path + fileName

            width: window.slotWidth
            height: window.slotHeight
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            z: active ? 10 : 1

            // Shear on outer host + layer AA, rounded clip on child only.
            // Reverse-shearing the image against a rounded clip left dirty corners.
            Item {
                id: card
                anchors.centerIn: parent
                width: window.cardWidth
                height: window.cardHeight
                scale: active ? window.activeScale : window.inactiveScale
                opacity: 1.0
                y: active ? 0 : window.inactiveYOffset
                transformOrigin: Item.Center
                transform: Shear {
                    xFactor: window.skewFactor
                }
                layer.enabled: true
                layer.smooth: true

                Behavior on scale {
                    enabled: window.initialFocusSet

                    NumberAnimation {
                        duration: 340
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

                ClippingRectangle {
                    anchors.fill: parent
                    radius: Constants.panelRadius
                    color: Colors.surfaceContainerLowest
                    border.width: Constants.borderWidth
                    border.color: Colors.surfaceContainerHighest

                    Image {
                        id: img
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: delegateRoot.thumbSource
                        asynchronous: true
                        cache: false
                        smooth: true
                        mipmap: true

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
                        radius: parent.radius
                        color: active ? "transparent" : Tokens.scrim
                    }

                    Text {
                        visible: img.status !== Image.Ready
                        text: img.status === Image.Error ? "Caching" : "Loading..."
                        color: Colors.primary
                        anchors.centerIn: parent
                        font.pixelSize: Constants.fontSizeLg
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
            // List focused: full nav. Click a card or Down from search to get here.
            if (event.key === Qt.Key_J || event.key === Qt.Key_Right || event.key === Qt.Key_PageDown) {
                window.stepSelection(1, 320)

            } else if (event.key === Qt.Key_K || event.key === Qt.Key_Left || event.key === Qt.Key_PageUp) {
                window.stepSelection(-1, 320)

            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                window.activateCurrent()

            } else if (event.key === Qt.Key_Slash || event.key === Qt.Key_Up) {
                searchField.forceActiveFocus()
                searchField.selectAll()

            } else if (event.key === Qt.Key_Escape) {
                window.closeRequested()

            } else return

            event.accepted = true
        }
    }
}
