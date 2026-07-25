import Quickshell
import Quickshell.Io
import QtQuick
import "../config" as Config

Scope {
    id: root

    property var entries: []
    property bool loading: false
    property string decodedEntryId: ""
    property string decodedText: ""
    property string decodeState: "idle"
    property string pendingDecodeId: ""
    property string runningDecodeId: ""

    signal copyFinished(bool success)

    function imageMetadata(preview) {
        const match = preview.match(/^\[\[ binary data\s+([0-9]+(?:\.[0-9]+)?\s+(?:B|KiB|MiB|GiB))\s+([a-zA-Z0-9.+-]+)\s+(\d+)x(\d+)\s*\]\]$/)
        if (!match)
            return ({ format: "", sizeLabel: "", width: 0, height: 0 })

        return {
            sizeLabel: match[1],
            format: match[2].toUpperCase(),
            width: Number(match[3]),
            height: Number(match[4])
        }
    }

    function parseEntries(output) {
        return output.split("\n")
            .filter(line => line.length > 0)
            .map(line => {
                const separator = line.indexOf("\t")
                const id = separator >= 0 ? line.slice(0, separator) : line
                const preview = separator >= 0 ? line.slice(separator + 1) : ""
                const image = preview.startsWith("[[ binary data")
                const metadata = image ? root.imageMetadata(preview) : ({})
                return {
                    id: id,
                    preview: image ? "Image" : preview,
                    rawPreview: preview,
                    image: image,
                    format: metadata.format ?? "",
                    sizeLabel: metadata.sizeLabel ?? "",
                    width: metadata.width ?? 0,
                    height: metadata.height ?? 0
                }
            })
    }

    function refresh() {
        loading = true
        listProcess.exec(["cliphist", "list"])
    }

    function copy(entry) {
        if (!entry?.id)
            return

        copyProcess.exec([
            "sh",
            "-c",
            "cliphist decode \"$1\" | wl-copy",
            "clipboard-copy",
            String(entry.id)
        ])
    }

    function preview(entry) {
        decodeTimer.stop()
        decodeProcess.running = false
        runningDecodeId = ""
        decodedEntryId = String(entry?.id ?? "")
        decodedText = ""

        if (!decodedEntryId) {
            decodeState = "idle"
            return
        }

        if (entry?.image) {
            decodeState = "ready"
            return
        }

        pendingDecodeId = decodedEntryId
        decodeState = "loading"
        decodeTimer.restart()
    }

    function isColor(value) {
        const text = String(value ?? "").trim()
        if (/^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(text))
            return true

        const rgb = text.match(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})(?:\s*,\s*(?:0|1|0?\.\d+))?\s*\)$/)
        return Boolean(rgb)
            && Number(rgb[1]) <= 255
            && Number(rgb[2]) <= 255
            && Number(rgb[3]) <= 255
    }

    function isUrl(value) {
        return /^https?:\/\/\S+$/i.test(String(value ?? "").trim())
    }

    function hostForUrl(value) {
        const match = String(value ?? "").trim().match(/^https?:\/\/([^/?#]+)/i)
        if (!match)
            return ""
        const authority = match[1].split("@").pop()
        return authority.replace(/:\d+$/, "").toLowerCase()
    }

    function faviconForUrl(value) {
        const host = hostForUrl(value)
        if (!host || !Config.IslandConstants.clipboardShowLinkVisuals)
            return ""
        return Config.IslandConstants.clipboardFaviconService + encodeURIComponent(host) + ".ico"
    }

    function canPreviewImage(entry) {
        if (!entry?.image)
            return false
        if (!entry.width || !entry.height)
            return true
        return entry.width * entry.height <= Config.IslandConstants.clipboardMaximumPreviewPixels
    }

    function typeFor(entry, decodedValue) {
        if (entry?.image)
            return "Image"
        const value = String(decodedValue || entry?.preview || "").trim()
        if (isColor(value))
            return "Color"
        if (isUrl(value))
            return "Link"
        return "Text"
    }

    Process {
        id: listProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.entries = root.parseEntries(text)
                root.loading = false
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root.entries = []
                root.loading = false
            }
        }
    }

    Process {
        id: copyProcess

        onExited: exitCode => root.copyFinished(exitCode === 0)
    }

    Timer {
        id: decodeTimer
        interval: 75
        onTriggered: {
            root.runningDecodeId = root.pendingDecodeId
            decodeProcess.exec(["cliphist", "decode", root.runningDecodeId])
        }
    }

    Process {
        id: decodeProcess

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.runningDecodeId !== root.decodedEntryId)
                    return
                root.decodedText = text
                root.decodeState = "ready"
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0 && root.runningDecodeId === root.decodedEntryId)
                root.decodeState = "error"
        }
    }
}
