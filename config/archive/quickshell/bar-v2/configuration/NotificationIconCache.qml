pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var paths: ({})

    function hasEntry(key) {
        return key.length > 0 && paths.hasOwnProperty(key)
    }

    function pathFor(key) {
        if (!hasEntry(key))
            return null
        return paths[key]
    }

    function store(key, value) {
        if (key.length === 0)
            return
        const copy = Object.assign({}, paths)
        copy[key] = value
        paths = copy
    }

    function warm(key) {
        if (key.length === 0 || hasEntry(key))
            return
        warmQueue.push(key)
        pumpWarmQueue()
    }

    property var warmQueue: []
    property bool warming: false

    function pumpWarmQueue() {
        if (warming || warmQueue.length === 0)
            return
        warming = true
        const key = warmQueue.shift()
        warmProcess.key = key
        warmProcess.running = false
        warmProcess.running = true
    }

    property Process warmProcess: Process {
        property string key: ""

        command: ["bash", Quickshell.shellPath("scripts/find-icon.sh"), key]

        stdout: SplitParser {
            onRead: path => {
                const trimmed = path.trim()
                const result = trimmed.length > 0 ? "file://" + trimmed : ""
                root.store(warmProcess.key, result)
            }
        }

        onExited: {
            if (!root.hasEntry(warmProcess.key))
                root.store(warmProcess.key, "")
            root.warming = false
            root.pumpWarmQueue()
        }
    }
}
