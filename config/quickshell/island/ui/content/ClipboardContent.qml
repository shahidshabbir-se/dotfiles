import Quickshell
import QtQuick
import Qt5Compat.GraphicalEffects
import "../../config" as Config

FocusScope {
    id: root

    required property var contentModel
    required property var palette

    signal actionRequested(string action, var argument)

    readonly property real preferredWidth: Config.IslandConstants.clipboardWidth
    readonly property real preferredHeight: Config.IslandConstants.clipboardHeight
    readonly property var source: contentModel?.source
    readonly property var entries: source?.entries ?? []
    readonly property string query: searchInput.text.trim().toLowerCase()
    readonly property var selectedEntry: filteredEntries.values[selectedIndex] ?? null
    property int selectedIndex: -1
    property string typeFilter: "All"

    focus: true

    function entryType(entry) {
        return source?.typeFor(entry, "") ?? "Text"
    }

    function searchableText(entry) {
        return [
            entry?.preview ?? "",
            entry?.rawPreview ?? "",
            entryType(entry)
        ].join(" ").toLowerCase()
    }

    function moveSelection(delta) {
        const count = filteredEntries.values.length
        if (count <= 0) {
            selectedIndex = -1
            return
        }

        selectedIndex = Math.max(0, Math.min(count - 1, selectedIndex + delta))
        resultList.currentIndex = selectedIndex
        resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function pasteSelected() {
        if (selectedEntry)
            actionRequested("pasteClipboard", selectedEntry)
    }

    function openSelectedUrl() {
        if (source?.isUrl(source.decodedText))
            actionRequested("openClipboardUrl", source.decodedText.trim())
    }

    function cycleTypeFilter() {
        const filters = ["All", "Text", "Image", "Link", "Color"]
        const nextIndex = (filters.indexOf(typeFilter) + 1) % filters.length
        typeFilter = filters[nextIndex]
    }

    onSelectedEntryChanged: source?.preview(selectedEntry)
    Component.onCompleted: focusTimer.restart()

    ScriptModel {
        id: filteredEntries

        values: root.entries.filter(entry => {
            const matchesQuery = !root.query || root.searchableText(entry).includes(root.query)
            const matchesType = root.typeFilter === "All" || root.entryType(entry) === root.typeFilter
            return matchesQuery && matchesType
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
        onTriggered: searchInput.forceActiveFocus()
    }

    Row {
        id: header
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Config.IslandConstants.clipboardPadding
        }
        height: Config.IslandConstants.clipboardSearchHeight
        spacing: Config.IslandConstants.clipboardContentSpacing

        Rectangle {
            width: parent.width - typeFilterButton.width - parent.spacing
            height: parent.height
            radius: height / 2
            color: root.palette.surfaceContainerHigh

            Text {
                id: searchIcon
                anchors {
                    left: parent.left
                    leftMargin: 14
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
                    leftMargin: 10
                    right: resultCount.left
                    rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                color: root.palette.surfaceForeground
                selectionColor: root.palette.primaryContainer
                selectedTextColor: root.palette.primaryContainerForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 15
                clip: true

                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) {
                        root.moveSelection(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        root.moveSelection(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_PageDown) {
                        root.moveSelection(Config.IslandConstants.clipboardVisibleResults)
                        event.accepted = true
                    } else if (event.key === Qt.Key_PageUp) {
                        root.moveSelection(-Config.IslandConstants.clipboardVisibleResults)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.actionRequested("dismiss", null)
                        event.accepted = true
                    } else if (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier)) {
                        root.cycleTypeFilter()
                        event.accepted = true
                    } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                            && (event.modifiers & Qt.ControlModifier)) {
                        root.openSelectedUrl()
                        event.accepted = true
                    } else if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
                        root.source?.refresh()
                        event.accepted = true
                    }
                }
                onAccepted: root.pasteSelected()
                onTextChanged: root.selectedIndex = 0

                Text {
                    anchors.fill: parent
                    visible: !searchInput.text
                    text: "Filter clipboard previews"
                    color: root.palette.surfaceVariantForeground
                    font: searchInput.font
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                id: resultCount
                anchors {
                    right: parent.right
                    rightMargin: 13
                    verticalCenter: parent.verticalCenter
                }
                text: filteredEntries.values.length + " / " + root.entries.length
                color: root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 11
            }
        }

        Rectangle {
            id: typeFilterButton
            width: 92
            height: parent.height
            radius: height / 2
            color: root.palette.surfaceContainerHigh

            Text {
                anchors.centerIn: parent
                text: root.typeFilter
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.cycleTypeFilter()
            }
        }
    }

    Row {
        anchors {
            top: header.bottom
            topMargin: Config.IslandConstants.clipboardContentSpacing
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Config.IslandConstants.clipboardPadding
            rightMargin: Config.IslandConstants.clipboardPadding
            bottomMargin: Config.IslandConstants.clipboardPadding
        }
        spacing: Config.IslandConstants.clipboardPaneSpacing

        ListView {
            id: resultList
            width: Config.IslandConstants.clipboardListWidth
            height: parent.height
            clip: true
            model: filteredEntries
            currentIndex: root.selectedIndex
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationWraps: false

            highlight: Rectangle {
                radius: 10
                color: root.palette.primaryContainer
            }
            highlightMoveDuration: 100
            highlightResizeDuration: 100

            delegate: Item {
                id: resultRow

                required property var modelData
                required property int index

                width: resultList.width
                height: Config.IslandConstants.clipboardResultHeight
                readonly property string type: root.entryType(modelData)
                readonly property string favicon: type === "Link"
                    ? root.source?.faviconForUrl(modelData.preview) ?? ""
                    : ""
                readonly property bool canPreviewImage: type === "Image"
                    && (root.source?.canPreviewImage(modelData) ?? false)

                Item {
                    id: previewSlot
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    width: Config.IslandConstants.clipboardThumbnailSize
                    height: Config.IslandConstants.clipboardThumbnailSize

                    ClipboardImageCache {
                        id: imageCache
                        entryId: resultRow.canPreviewImage ? String(resultRow.modelData.id) : ""
                    }

                    Item {
                        id: roundedThumbnail
                        anchors.fill: parent
                        visible: resultRow.type === "Image" && thumbnail.status === Image.Ready
                        layer.enabled: visible
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: roundedThumbnail.width
                                height: roundedThumbnail.height
                                radius: 7
                            }
                        }

                        Image {
                            id: thumbnail
                            anchors.fill: parent
                            source: imageCache.source
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(64, 64)
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        visible: resultRow.type === "Color"
                        width: 20
                        height: 20
                        radius: width / 2
                        color: previewPane.parseColor(resultRow.modelData.preview)
                        border.width: 3
                        border.color: root.palette.outline
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: resultRow.type === "Text"
                        radius: 7
                        color: root.palette.surfaceContainerHigh
                    }

                    Item {
                        id: roundedFavicon
                        anchors.centerIn: parent
                        visible: resultRow.type === "Link" && favicon.status === Image.Ready
                        width: 22
                        height: 22
                        layer.enabled: visible
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: roundedFavicon.width
                                height: roundedFavicon.height
                                radius: 6
                            }
                        }

                        Image {
                            id: favicon
                            anchors.fill: parent
                            source: resultRow.favicon
                            asynchronous: true
                            fillMode: Image.PreserveAspectCrop
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: (resultRow.type === "Image" && thumbnail.status !== Image.Ready)
                            || (resultRow.type === "Link" && favicon.status !== Image.Ready)
                            || resultRow.type === "Text"
                        text: {
                            if (resultRow.type === "Link") return "↗"
                            if (resultRow.type === "Image") return Config.IslandConstants.imageIcon
                            return "T"
                        }
                        color: root.palette.surfaceVariantForeground
                        font.family: resultRow.type === "Image"
                            ? Config.IslandConstants.iconFontFamily
                            : Config.IslandConstants.textFontFamily
                        font.pixelSize: resultRow.type === "Text" ? 14 : Config.IslandConstants.clipboardIconSize
                        font.weight: Font.Bold
                    }
                }

                Column {
                    anchors {
                        left: previewSlot.right
                        leftMargin: 9
                        right: parent.right
                        rightMargin: 7
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 1

                    Text {
                        width: parent.width
                        text: resultRow.modelData.preview
                        textFormat: Text.PlainText
                        color: root.palette.surfaceForeground
                        font.family: Config.IslandConstants.textFontFamily
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: {
                            if (resultRow.type !== "Image") return resultRow.type
                            const details = [resultRow.modelData.format]
                            if (resultRow.modelData.width)
                                details.push(resultRow.modelData.width + "×" + resultRow.modelData.height)
                            return details.filter(Boolean).join(" · ") || "Image"
                        }
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
                    onClicked: {
                        root.selectedIndex = resultRow.index
                        resultList.currentIndex = resultRow.index
                        root.actionRequested("pasteClipboard", resultRow.modelData)
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - 16
                visible: filteredEntries.values.length === 0
                text: root.source?.loading
                    ? "Loading history…"
                    : root.query
                        ? "No matching previews"
                        : "Clipboard history is empty"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                color: root.palette.surfaceVariantForeground
                font.family: Config.IslandConstants.textFontFamily
                font.pixelSize: 12
            }
        }

        Rectangle {
            width: 1
            height: parent.height
            color: root.palette.outlineVariant
            opacity: 0.55
        }

        ClipboardPreview {
            id: previewPane
            width: parent.width
                - Config.IslandConstants.clipboardListWidth
                - parent.spacing * 2
                - 1
            height: parent.height
            entry: root.selectedEntry
            source: root.source
            palette: root.palette
            onPasteRequested: entry => root.actionRequested("pasteClipboard", entry)
            onOpenUrlRequested: url => root.actionRequested("openClipboardUrl", url)
        }
    }
}
