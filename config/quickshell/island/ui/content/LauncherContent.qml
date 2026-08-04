import Quickshell
import Quickshell.Widgets
import QtQuick
import "../../config" as Config

FocusScope {
    id: root

    required property var contentModel
    required property var palette

    signal actionRequested(string action, var argument)

    readonly property real preferredWidth: Config.IslandConstants.launcherWidth
    readonly property real preferredHeight: Config.IslandConstants.launcherHeight
    readonly property var applications: contentModel?.source?.applications ?? []
    readonly property string query: searchInput.text.trim().toLowerCase()
    property int selectedIndex: 0

    focus: true

    function searchableText(app) {
        const keywords = app?.keywords
        const keywordText = keywords && keywords.join ? keywords.join(" ") : String(keywords ?? "")
        return [
            app?.name ?? "",
            app?.genericName ?? "",
            app?.comment ?? "",
            app?.id ?? "",
            keywordText
        ].join(" ").toLowerCase()
    }

    function matchScore(app) {
        if (!query)
            return 2
        const name = String(app?.name ?? "").toLowerCase()
        if (name === query)
            return 0
        if (name.startsWith(query))
            return 1
        return 2
    }

    function moveSelection(delta) {
        const count = filteredApps.values.length
        if (count <= 0) {
            selectedIndex = -1
            return
        }
        selectedIndex = Math.max(0, Math.min(count - 1, selectedIndex + delta))
        resultList.currentIndex = selectedIndex
        resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function launchSelected() {
        const app = filteredApps.values[selectedIndex]
        if (app)
            actionRequested("launchApp", app)
    }

    Component.onCompleted: focusTimer.restart()

    ScriptModel {
        id: filteredApps

        values: root.applications
            .filter(app => !root.query || root.searchableText(app).includes(root.query))
            .sort((a, b) => {
                const scoreDifference = root.matchScore(a) - root.matchScore(b)
                return scoreDifference || String(a.name).localeCompare(String(b.name))
            })

        onValuesChanged: {
            root.selectedIndex = values.length > 0 ? 0 : -1
            resultList.currentIndex = root.selectedIndex
            resultList.positionViewAtBeginning()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            searchInput.forceActiveFocus()
        }
    }

    Rectangle {
        id: searchField
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Config.IslandConstants.launcherPadding
        }
        height: Config.IslandConstants.launcherSearchHeight
        radius: Config.Radius.capsule(height)
        color: root.palette.surfaceContainerHigh

        Text {
            id: searchIcon
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            text: Config.IslandConstants.searchIcon
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.iconFontFamily
            font.pixelSize: 15
        }

        TextInput {
            id: searchInput
            anchors {
                left: searchIcon.right
                leftMargin: 12
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            color: root.palette.surfaceForeground
            selectionColor: root.palette.primaryContainer
            selectedTextColor: root.palette.primaryContainerForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: Config.IslandConstants.bodyFontSize
            clip: true

            Keys.priority: Keys.BeforeItem
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    root.moveSelection(1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    root.moveSelection(-1)
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    root.actionRequested("dismiss", null)
                    event.accepted = true
                }
            }
            onAccepted: root.launchSelected()
            onTextChanged: {
                root.selectedIndex = 0
                resultList.currentIndex = 0
            }

            Text {
                anchors.fill: parent
                visible: !searchInput.text
                text: "Search applications"
                color: root.palette.surfaceVariantForeground
                font: searchInput.font
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ListView {
        id: resultList
        anchors {
            top: searchField.bottom
            topMargin: Config.IslandConstants.launcherContentSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Config.IslandConstants.launcherPadding
            rightMargin: Config.IslandConstants.launcherPadding
            bottomMargin: Config.IslandConstants.launcherPadding
        }
        clip: true
        model: filteredApps
        currentIndex: root.selectedIndex
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationWraps: false

        highlight: Rectangle {
            radius: Config.Radius.lg
            color: root.palette.primaryContainer
        }
        highlightMoveDuration: 100
        highlightResizeDuration: 100

        delegate: Item {
            id: resultRow

            required property var modelData
            required property int index

            width: resultList.width
            height: Config.IslandConstants.launcherResultHeight

            IconImage {
                id: appIcon
                anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                implicitSize: Config.IslandConstants.launcherIconSize
                source: {
                    const icon = String(resultRow.modelData.icon ?? "")
                    if (!icon)
                        return Quickshell.iconPath("application-x-executable")
                    return icon.startsWith("/")
                        ? "file://" + icon
                        : Quickshell.iconPath(icon, "application-x-executable")
                }
            }

            Column {
                anchors {
                    left: appIcon.right
                    leftMargin: 12
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                spacing: 1

                Text {
                    width: parent.width
                    text: resultRow.modelData.name
                    color: root.palette.surfaceForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: text.length > 0
                    text: resultRow.modelData.genericName ?? ""
                    color: root.palette.surfaceVariantForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    root.selectedIndex = resultRow.index
                    resultList.currentIndex = resultRow.index
                }
                onClicked: root.actionRequested("launchApp", resultRow.modelData)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: filteredApps.values.length === 0
            text: "No applications found"
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 14
        }
    }
}
