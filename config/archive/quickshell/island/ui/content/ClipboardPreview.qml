import QtQuick
import Qt5Compat.GraphicalEffects
import "../../config" as Config

Item {
    id: root

    required property var entry
    required property var source
    required property var palette

    signal pasteRequested(var entry)
    signal openUrlRequested(string url)

    readonly property bool selectedDecoded: Boolean(source)
        && String(entry?.id ?? "") === source.decodedEntryId
    readonly property string decodedText: selectedDecoded ? source.decodedText : ""
    readonly property string contentType: source ? source.typeFor(entry, decodedText) : "Text"
    readonly property bool loading: !entry || (contentType !== "Image"
        && (!selectedDecoded || source?.decodeState === "loading"))
    readonly property bool failed: selectedDecoded && source?.decodeState === "error"
    readonly property string trimmedText: decodedText.trim()
    readonly property string hostName: {
        if (contentType !== "Link")
            return ""
        return trimmedText.replace(/^https?:\/\//i, "").split(/[/?#]/)[0]
    }
    readonly property string favicon: contentType === "Link" && source
        ? source.faviconForUrl(trimmedText)
        : ""
    readonly property int lineCount: decodedText
        ? decodedText.replace(/\n$/, "").split("\n").length
        : 0
    readonly property color swatchColor: parseColor(trimmedText)
    readonly property bool canPreviewImage: contentType === "Image"
        && (source?.canPreviewImage(entry) ?? false)

    function parseColor(value) {
        const hex = value.match(/^#([0-9a-fA-F]{3,8})$/)
        if (hex) {
            let digits = hex[1]
            if (digits.length === 3 || digits.length === 4)
                digits = digits.split("").map(character => character + character).join("")
            if (digits.length === 6)
                return Qt.rgba(
                    parseInt(digits.slice(0, 2), 16) / 255,
                    parseInt(digits.slice(2, 4), 16) / 255,
                    parseInt(digits.slice(4, 6), 16) / 255,
                    1
                )
            if (digits.length === 8)
                return Qt.rgba(
                    parseInt(digits.slice(0, 2), 16) / 255,
                    parseInt(digits.slice(2, 4), 16) / 255,
                    parseInt(digits.slice(4, 6), 16) / 255,
                    parseInt(digits.slice(6, 8), 16) / 255
                )
        }

        const rgb = value.match(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})(?:\s*,\s*(0|1|0?\.\d+))?\s*\)$/)
        if (rgb) {
            const red = Math.min(255, Number(rgb[1])) / 255
            const green = Math.min(255, Number(rgb[2])) / 255
            const blue = Math.min(255, Number(rgb[3])) / 255
            return Qt.rgba(red, green, blue, rgb[4] === undefined ? 1 : Number(rgb[4]))
        }
        return "transparent"
    }

    ClipboardImageCache {
        id: imageCache
        entryId: root.canPreviewImage ? String(root.entry.id) : ""
    }

    Text {
        id: typeLabel
        anchors {
            top: parent.top
            left: parent.left
        }
        text: root.contentType.toUpperCase()
        color: root.palette.surfaceVariantForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: 11
        font.weight: Font.Bold
        font.letterSpacing: 0.8
    }

    Text {
        anchors {
            top: parent.top
            right: parent.right
        }
        text: {
            if (root.contentType === "Image" && root.entry?.width)
                return root.entry.width + "×" + root.entry.height
            if (root.contentType === "Link")
                return root.trimmedText.toLowerCase().startsWith("https://") ? "HTTPS" : "HTTP"
            if (root.contentType === "Color")
                return root.trimmedText.startsWith("#") ? "HEX" : "RGB"
            if (root.contentType === "Text" && root.lineCount)
                return root.lineCount + (root.lineCount === 1 ? " line" : " lines")
            return ""
        }
        color: root.palette.surfaceVariantForeground
        font.family: Config.IslandConstants.textFontFamily
        font.pixelSize: 11
    }

    Item {
        id: previewArea
        anchors {
            top: typeLabel.bottom
            topMargin: 7
            left: parent.left
            right: parent.right
            bottom: footer.top
            bottomMargin: 7
        }

        Text {
            anchors.centerIn: parent
            visible: root.loading || root.failed || !root.entry
            text: root.failed
                ? "Preview unavailable"
                : root.entry
                    ? "Loading preview…"
                    : "Select an item to preview"
            color: root.failed ? root.palette.error : root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 13
        }

        Item {
            id: roundedImagePreview
            readonly property real aspectRatio: root.entry?.width > 0 && root.entry?.height > 0
                ? root.entry.width / root.entry.height
                : 1

            anchors.centerIn: parent
            width: aspectRatio >= parent.width / parent.height
                ? parent.width
                : parent.height * aspectRatio
            height: aspectRatio >= parent.width / parent.height
                ? parent.width / aspectRatio
                : parent.height
            visible: root.contentType === "Image" && root.canPreviewImage && !root.loading
            layer.enabled: visible
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: roundedImagePreview.width
                    height: roundedImagePreview.height
                    radius: Config.Radius.lg
                }
            }

            Image {
                anchors.fill: parent
                source: imageCache.source
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(720, 480)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root.contentType === "Image" && !root.canPreviewImage
            text: "Image too large to preview"
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 13
        }

        Column {
            anchors {
                fill: parent
                margins: 3
            }
            visible: root.contentType === "Color" && !root.loading && !root.failed
            spacing: 8

            Item {
                width: parent.width
                height: parent.height - colorValue.height - parent.spacing

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(104, parent.height - 4)
                    height: width
                    radius: Config.Radius.circle(width)
                    color: root.swatchColor
                    border.width: 4
                    border.color: root.palette.outline
                }
            }

            Text {
                id: colorValue
                width: parent.width
                text: root.trimmedText
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: root.palette.surfaceForeground
                font.family: Config.IslandConstants.monoFontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }

        Column {
            anchors {
                fill: parent
                margins: 4
            }
            visible: root.contentType === "Link" && !root.loading && !root.failed
            spacing: 8

            Row {
                width: parent.width
                height: 24
                spacing: 8

                Item {
                    id: roundedLinkFavicon
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    layer.enabled: linkFavicon.status === Image.Ready
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: roundedLinkFavicon.width
                            height: roundedLinkFavicon.height
                            radius: Config.Radius.md
                        }
                    }

                    Image {
                        id: linkFavicon
                        anchors.fill: parent
                        source: root.favicon
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - roundedLinkFavicon.width - parent.spacing
                    text: root.hostName
                    textFormat: Text.PlainText
                    color: root.palette.surfaceForeground
                    font.family: Config.IslandConstants.textFontFamily
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            TextEdit {
                width: parent.width
                height: parent.height - y
                text: root.trimmedText
                textFormat: TextEdit.PlainText
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.WrapAnywhere
                color: root.palette.surfaceVariantForeground
                selectionColor: root.palette.primaryContainer
                selectedTextColor: root.palette.primaryContainerForeground
                font.family: Config.IslandConstants.monoFontFamily
                font.pixelSize: 12
            }
        }

        Flickable {
            anchors.fill: parent
            visible: root.contentType === "Text" && !root.loading && !root.failed
            clip: true
            contentHeight: textPreview.contentHeight
            boundsBehavior: Flickable.StopAtBounds

            TextEdit {
                id: textPreview
                width: parent.width
                text: root.decodedText
                textFormat: TextEdit.PlainText
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.Wrap
                color: root.palette.surfaceForeground
                selectionColor: root.palette.primaryContainer
                selectedTextColor: root.palette.primaryContainerForeground
                font.family: Config.IslandConstants.monoFontFamily
                font.pixelSize: 13
            }
        }
    }

    Rectangle {
        id: footer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 27
        radius: Config.Radius.md
        color: root.palette.surfaceContainerHigh

        Text {
            anchors {
                left: parent.left
                leftMargin: 9
                verticalCenter: parent.verticalCenter
            }
            text: {
                if (root.contentType === "Image")
                    return [root.entry?.format, root.entry?.sizeLabel].filter(Boolean).join(" · ") || "Image"
                if (root.contentType === "Link")
                    return "Ctrl+Enter opens"
                return root.contentType
            }
            textFormat: Text.PlainText
            color: root.palette.surfaceVariantForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 11
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 9
                verticalCenter: parent.verticalCenter
            }
            text: "↵ Paste"
            color: root.palette.surfaceForeground
            font.family: Config.IslandConstants.textFontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        MouseArea {
            anchors.fill: parent
            enabled: Boolean(root.entry)
            cursorShape: Qt.PointingHandCursor
            onClicked: root.pasteRequested(root.entry)
        }
    }
}
