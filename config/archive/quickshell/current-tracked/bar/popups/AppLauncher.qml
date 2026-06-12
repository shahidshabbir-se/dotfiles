import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.configuration

Scope {
    id: launcher

    property bool open: false
    property string searchText: ""
    property int selectedIndex: 0

    readonly property string homeDir: {
        const home = Quickshell.env("HOME") ?? ""
        if (home.length > 0)
            return home

        const cacheHome = Quickshell.env("XDG_CACHE_HOME") ?? ""
        if (cacheHome.endsWith("/.cache"))
            return cacheHome.slice(0, -"/.cache".length)

        return ""
    }

    property int bannerCandidateIndex: 0

    function fileUrl(absolutePath) {
        if (!absolutePath || absolutePath.length === 0)
            return ""
        return absolutePath.startsWith("file://") ? absolutePath : "file://" + absolutePath
    }

    readonly property var bannerCandidates: {
        const urls = []
        if (homeDir.length > 0) {
            urls.push(fileUrl(homeDir + "/.cache/amadeus-bar/menu-banner.png"))
            urls.push(fileUrl(homeDir + "/.cache/hyprlock.png"))
        }
        urls.push(Qt.resolvedUrl("../assets/menu-banner.png"))
        return urls
    }

    readonly property string bannerSource: {
        if (bannerCandidates.length === 0)
            return ""
        const index = Math.max(0, Math.min(bannerCandidateIndex, bannerCandidates.length - 1))
        return bannerCandidates[index]
    }

    function resetBannerSource() {
        bannerCandidateIndex = 0
    }

    function tryNextBannerSource() {
        if (bannerCandidateIndex + 1 < bannerCandidates.length)
            bannerCandidateIndex++
    }
    readonly property var activeScreen: Quickshell.screens.find(
        screen => screen.name === Hyprland.focusedMonitor?.name
    ) ?? Quickshell.screens[0] ?? null

    readonly property var allApps: DesktopEntries.applications.values
        .filter(app => app && app.name && app.name.length > 0)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var filteredApps: {
        const query = searchText.trim().toLowerCase()
        if (query.length === 0)
            return allApps

        return allApps.filter(app => {
            const haystack = [
                app.name ?? "",
                app.genericName ?? "",
                app.comment ?? "",
                (app.keywords ?? []).join(" "),
                (app.categories ?? []).join(" "),
            ].join(" ").toLowerCase()

            return haystack.includes(query)
        })
    }

    function clampSelection() {
        if (filteredApps.length === 0) {
            selectedIndex = 0
            return
        }

        selectedIndex = Math.max(0, Math.min(selectedIndex, filteredApps.length - 1))
    }

    function resetSelection() {
        selectedIndex = 0
    }

    function close() {
        open = false
        searchText = ""
        resetSelection()
    }

    function toggle() {
        open = !open
        if (!open) {
            searchText = ""
            resetSelection()
        } else {
            resetBannerSource()
        }
    }

    function launch(entry) {
        if (!entry)
            return

        entry.execute()
        close()
    }

    function iconSource(iconName) {
        const cleanName = (iconName ?? "").split("?")[0]
        const source = cleanName.length > 0 ? Quickshell.iconPath(cleanName, true) : ""

        return source && source.length > 0
            ? source
            : Quickshell.iconPath("application-x-executable", true)
    }

    onFilteredAppsChanged: resetSelection()

    IpcHandler {
        target: "launcher"

        function toggle(): void { launcher.toggle() }
        function openMenu(): void {
            launcher.resetBannerSource()
            launcher.open = true
        }
        function closeMenu(): void { launcher.close() }
    }

    LazyLoader {
        loading: true
        active: launcher.open

        Scope {
            PopupBackdrop {
                open: launcher.open
                screen: launcher.activeScreen
                onClickedOutside: launcher.close()
            }

            PanelWindow {
                screen: launcher.activeScreen
                visible: launcher.open && launcher.activeScreen !== null
                exclusionMode: ExclusionMode.Ignore
                focusable: true
                aboveWindows: true
                anchors.left: true
                anchors.top: true
                margins.left: BarMetrics.popupLeftMargin(launcher.activeScreen)
                margins.top: BarMetrics.popupTopMargin
                implicitWidth: 380
                implicitHeight: 560
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell_launcher_popup"

                Rectangle {
                    id: launcherPanel
                    anchors.fill: parent
                    radius: 10
                    color: Colors.barBackground
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        z: 0
                        acceptedButtons: Qt.AllButtons
                        onClicked: mouse => mouse.accepted = true
                        onWheel: wheel => wheel.accepted = true
                    }

                    ColumnLayout {
                        z: 1
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 168
                            radius: 8
                            color: Colors.moduleBackground
                            border.width: 1
                            border.color: Colors.moduleBorder
                            clip: true

                            Image {
                                id: bannerImage
                                anchors.fill: parent
                                source: launcher.bannerSource
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(380, 168)
                                asynchronous: true
                                cache: false
                                opacity: status === Image.Ready ? 0.52 : 0

                                Behavior on opacity {
                                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                                }

                                onStatusChanged: {
                                    if (status === Image.Error)
                                        launcher.tryNextBannerSource()
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 270
                                height: 36
                                radius: 8
                                color: Colors.moduleBackground
                                border.width: 1
                                border.color: Colors.moduleBorder

                                TextInput {
                                    id: searchField
                                    anchors.fill: parent
                                    anchors.leftMargin: 11
                                    anchors.rightMargin: 11
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: launcher.searchText
                                    color: Colors.textPrimary
                                    selectedTextColor: Colors.barBackground
                                    selectionColor: Colors.workspaceActive
                                    font.family: "Cartograph CF"
                                    font.pixelSize: 13
                                    clip: true
                                    focus: launcher.open
                                    onTextChanged: launcher.searchText = text

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Search..."
                                        color: Colors.textMuted
                                        visible: searchField.text.length === 0
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 13
                                    }

                                    Keys.onEscapePressed: launcher.close()
                                    Keys.onDownPressed: {
                                        if (launcher.filteredApps.length === 0)
                                            return
                                        launcher.selectedIndex = Math.min(
                                            launcher.selectedIndex + 1,
                                            launcher.filteredApps.length - 1
                                        )
                                        appList.positionViewAtIndex(launcher.selectedIndex, ListView.Contain)
                                    }
                                    Keys.onUpPressed: {
                                        if (launcher.filteredApps.length === 0)
                                            return
                                        launcher.selectedIndex = Math.max(launcher.selectedIndex - 1, 0)
                                        appList.positionViewAtIndex(launcher.selectedIndex, ListView.Contain)
                                    }
                                    Keys.onReturnPressed: launcher.launch(launcher.filteredApps[launcher.selectedIndex])
                                    Keys.onEnterPressed: launcher.launch(launcher.filteredApps[launcher.selectedIndex])
                                }
                            }
                        }

                        ListView {
                            id: appList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 5
                            model: launcher.filteredApps
                            currentIndex: launcher.selectedIndex
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: appList.width
                                height: 39
                                radius: 8
                                color: index === launcher.selectedIndex
                                    ? Colors.moduleBackgroundHover
                                    : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 18
                                    anchors.rightMargin: 18
                                    spacing: 12

                                    Image {
                                        Layout.preferredWidth: 26
                                        Layout.preferredHeight: 26
                                        source: launcher.iconSource(modelData.icon)
                                        sourceSize.width: 52
                                        sourceSize.height: 52
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: Colors.textPrimary
                                        elide: Text.ElideRight
                                        font.family: "Cartograph CF"
                                        font.pixelSize: 13
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: launcher.selectedIndex = index
                                    onClicked: launcher.launch(modelData)
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: launcher.filteredApps.length === 0
                                text: "No applications found"
                                color: Colors.textSecondary
                                font.family: "Cartograph CF"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}
