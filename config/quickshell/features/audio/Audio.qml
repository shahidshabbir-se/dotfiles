pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

// Audio feature facade: PipeWire state, the panel's keyboard cursor, and the
// overlay window. The bar button talks to this through `open` / `toggle()` and
// reads `icon` / `outputMuted` for its glyph — no child IDs cross the boundary.
Scope {
    id: root

    required property var screen
    // Floating bar geometry, so the panel can sit under the bar the same way the
    // notification center does.
    property bool barVertical: false
    property int barWidth: 0

    property bool open: false

    readonly property string backend: Quickshell.shellPath("features/audio/scripts/qs-audio")

    function toggle() {
        open = !open
    }

    function close() {
        open = false
    }

    // ---------- PipeWire state ----------

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var mprisPlayers: Mpris.players ? Mpris.players.values : []

    // Playing player, preferring one that owns a visible stream: that is the app
    // the SOURCES section is already showing.
    readonly property var activePlayer: {
        let fallback = null
        for (let i = 0; i < mprisPlayers.length; i++) {
            const player = mprisPlayers[i]
            if (!player)
                continue
            if (!player.isPlaying) {
                if (!fallback)
                    fallback = player
                continue
            }
            for (let j = 0; j < displayAudioStreams.length; j++) {
                if (streamRepresentsPlayer(displayAudioStreams[j], player))
                    return player
            }
            fallback = player
        }
        return fallback
    }

    readonly property var candidateSinks: {
        const list = []
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i]
            if (node && node.isSink && !node.isStream)
                list.push(node)
        }
        return list
    }

    readonly property var candidateSources: {
        const list = []
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i]
            if (!node || node.isSink || node.isStream || !AudioLabels.isAudioSource(node))
                continue
            // This shell's own capture node would otherwise show up as an input
            // device the user cannot do anything with.
            if (String(node.name || "") === "quickshell")
                continue
            list.push(node)
        }
        return list
    }

    readonly property var candidateStreams: {
        const list = []
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i]
            if (!node || !AudioLabels.isPlaybackStream(node))
                continue
            // A speaker tuning is a playback stream too, but it is the processing
            // itself rather than an application, so it does not belong in the list.
            if (String(node.name || "").indexOf("omarchy_speaker_tuning") === 0)
                continue
            if (!node.audio)
                continue
            list.push(node)
        }
        return list
    }

    // Repeaters are fed panel-local snapshots instead of the live PipeWire model:
    // PipeWire removes nodes while Quickshell dispatches that removal, and
    // rebuilding a Repeater from that signal path has crashed the service. The
    // refresh timer lets the mutation settle first, and a closed panel keeps its
    // repeaters detached entirely.
    property var displayAudioSinks: []
    property var displayAudioSources: []
    property var displayAudioStreams: []

    function refreshDisplayModels() {
        if (!root.open)
            return
        displayAudioSinks = AudioLabels.listSnapshot(candidateSinks)
        displayAudioSources = AudioLabels.listSnapshot(candidateSources)
        displayAudioStreams = AudioLabels.listSnapshot(candidateStreams)
        root.clampCursor()
    }

    function scheduleDisplayRefresh() {
        if (!root.open)
            return
        displayRefreshTimer.restart()
    }

    function clearDisplayModels() {
        displayRefreshTimer.stop()
        displayAudioSinks = []
        displayAudioSources = []
        displayAudioStreams = []
    }

    onNodesChanged: root.scheduleDisplayRefresh()
    onMprisPlayersChanged: root.scheduleDisplayRefresh()

    // The default output can be a DSP sink — a speaker tuning, or EasyEffects —
    // which is not where loudness lives: its volume is the level going *into*
    // the processing, so the slider would move while the speakers did not, and
    // on a chain with a limiter it would change the tone too. qs-audio resolves
    // the current default through any such sink to the physical one, which is
    // the same sink the volume keys change.
    property string volumeSinkName: ""

    readonly property var volumeSink: {
        if (!root.sink || root.volumeSinkName === "")
            return root.sink
        if (root.volumeSinkName === String(root.sink.name))
            return root.sink
        for (let i = 0; i < root.nodes.length; i++) {
            const node = root.nodes[i]
            if (node && node.isSink && !node.isStream
                    && String(node.name) === root.volumeSinkName && node.audio)
                return node
        }
        return root.sink
    }

    function resolveVolumeSink() {
        if (outputSinkProc.running)
            outputSinkProc.running = false
        Qt.callLater(() => {
            if (!outputSinkProc.running)
                outputSinkProc.running = true
        })
    }

    onSinkChanged: root.resolveVolumeSink()

    readonly property real outputVolume: volumeSink && volumeSink.audio ? volumeSink.audio.volume : 0
    readonly property bool outputMuted: volumeSink && volumeSink.audio ? volumeSink.audio.muted : false
    readonly property real inputVolume: source && source.audio ? source.audio.volume : 0
    readonly property bool inputMuted: source && source.audio ? source.audio.muted : false

    // Only channels that exist get a vote: a box with no input would otherwise
    // read as "unmuted" forever, leaving the hero switch able to mute but never
    // to unmute.
    readonly property bool hasOutput: !!(volumeSink && volumeSink.audio)
    readonly property bool hasInput: !!(source && source.audio)
    readonly property bool anyAudible: (hasOutput && !outputMuted) || (hasInput && !inputMuted)
    readonly property bool hasInputSection: displayAudioSources.length > 0 || hasInput

    // ---------- Actions ----------

    // Volume and mute writes go through qs-audio (wpctl), not through
    // PwNodeAudio: PipeWire silently drops a QML write on some nodes — a
    // bluetooth microphone here accepted the new value in the QML readback
    // while the real node never moved — while wpctl lands on the same node
    // every time. Reading stays in QML, so the sliders still track live.
    //
    // Dragging asks for up to twenty changes a second and each one is a
    // process spawn, so only the newest request in a 40ms window is sent.
    property var pendingWrite: null

    function queueWrite(args) {
        root.pendingWrite = args
        if (!writeTimer.running)
            writeTimer.restart()
    }

    Timer {
        id: writeTimer

        // Short enough that the sink tracks the pointer, long enough that a
        // fast drag does not fork a process per pixel.
        interval: 25
        repeat: false
        onTriggered: {
            const args = root.pendingWrite
            root.pendingWrite = null
            if (args)
                Quickshell.execDetached([root.backend].concat(args))
        }
    }

    function outputIcon() {
        // Material speaker icons render visually smaller in JetBrainsMono Nerd Font.
        if (!hasOutput)
            return "󰝟"
        if (AudioLabels.isHeadphones(volumeSink))
            return "󰋋"
        if (outputMuted)
            return "󰝟"
        if (outputVolume >= 0.67)
            return "󰕾"
        if (outputVolume >= 0.34)
            return "󰖀"
        if (outputVolume > 0)
            return "󰕿"
        return "󰝟"
    }

    function statusName() {
        if (hasInputSection && inputMuted && (!hasOutput || outputMuted))
            return "Muted"
        return AudioLabels.outputVolumeName(outputVolume, outputMuted)
    }

    function setOutputVolume(value) {
        if (!hasOutput)
            return
        const level = Math.max(0, Math.min(1, value))
        root.queueWrite(["set-volume", String(volumeSink.id), level.toFixed(3)])
    }

    function setInputVolume(value) {
        if (!hasInput)
            return
        const level = Math.max(0, Math.min(1, value))
        root.queueWrite(["set-volume", String(source.id), level.toFixed(3)])
    }

    function toggleOutputMute() {
        if (hasOutput)
            root.queueWrite(["set-mute", String(volumeSink.id), outputMuted ? "0" : "1"])
    }

    function toggleInputMute() {
        if (hasInput)
            root.queueWrite(["set-mute", String(source.id), inputMuted ? "0" : "1"])
    }

    // The hero switch is the whole panel's on/off, so it carries both channels
    // at once and reads as on while anything is still audible.
    function toggleAllMuted() {
        // The hero switch is the panel's on/off: muted means audible, so a
        // live channel gets muted and a dead one is switched back on.
        const mute = root.anyAudible ? "1" : "0"
        if (hasOutput)
            root.queueWrite(["set-mute", String(volumeSink.id), mute])
        if (hasInput)
            root.queueWrite(["set-mute", String(source.id), mute])
    }

    function toggleStreamMute(node) {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted
    }

    function setDefaultSink(node) {
        if (!node)
            return
        Pipewire.preferredDefaultAudioSink = node
        if (node.id !== undefined)
            Quickshell.execDetached([root.backend, "set-default-output", String(node.id)])
    }

    function setDefaultSource(node) {
        if (!node)
            return
        Pipewire.preferredDefaultAudioSource = node
        if (node.id !== undefined)
            Quickshell.execDetached([root.backend, "set-default-input", String(node.id)])
    }

    function streamLabel(node) {
        return AudioLabels.streamLabel(node, root.mprisPlayers, root.displayAudioStreams)
    }

    function streamRepresentsPlayer(node, player) {
        return AudioLabels.streamRepresentsPlayer(
            node, player, root.mprisPlayers, root.displayAudioStreams)
    }

    // ---------- Keyboard cursor ----------
    //
    // One model for both keyboard and mouse, with sections in visual order:
    //   "header"  — the hero switch (virtual: it sits above every section)
    //   "output"  — output slider + sink rows
    //   "input"   — input slider + source rows
    //   "streams" — per-app stream rows
    // selectedIndex inside a section: -1 is the slider row, 0..N-1 a device row.
    property bool cursorActive: false
    property string focusSection: "output"
    property int selectedIndex: -1

    // Injected by AudioPanel: the cursor needs a scroller to keep itself visible.
    property var scroller: null

    readonly property var visibleSections: {
        const list = ["output"]
        if (root.hasInputSection)
            list.push("input")
        if (root.displayAudioStreams.length > 0)
            list.push("streams")
        return list
    }

    function sectionCount(section) {
        if (section === "output")
            return root.displayAudioSinks.length
        if (section === "input")
            return root.displayAudioSources.length
        if (section === "streams")
            return root.displayAudioStreams.length
        return 0
    }

    function sectionHasSlider(section) {
        return section === "output" || section === "input"
    }

    function sectionFloor(section) {
        return root.sectionHasSlider(section) ? -1 : 0
    }

    function setCursor(section, index) {
        root.cursorActive = true
        root.focusSection = section
        root.selectedIndex = index
    }

    function setHeaderCursor() {
        root.setCursor("header", -1)
    }

    function revealCursor() {
        root.cursorActive = true
        root.selectedIndex = -1
    }

    function moveCursor(delta) {
        const sections = root.visibleSections
        if (root.focusSection === "header") {
            if (delta < 0)
                return
            root.focusSection = sections[0]
            root.selectedIndex = root.sectionFloor(root.focusSection)
            return
        }

        const sectionIndex = sections.indexOf(root.focusSection)
        if (sectionIndex < 0) {
            root.focusSection = sections[0]
            root.selectedIndex = root.sectionFloor(root.focusSection)
            return
        }

        const last = root.sectionCount(root.focusSection) - 1
        if (delta > 0) {
            if (root.selectedIndex < last) {
                root.selectedIndex += 1
                return
            }
            if (sectionIndex < sections.length - 1) {
                root.focusSection = sections[sectionIndex + 1]
                root.selectedIndex = root.sectionFloor(root.focusSection)
            }
            return
        }

        if (root.selectedIndex > root.sectionFloor(root.focusSection)) {
            root.selectedIndex -= 1
            return
        }
        if (sectionIndex > 0) {
            root.focusSection = sections[sectionIndex - 1]
            const previousLast = root.sectionCount(root.focusSection) - 1
            root.selectedIndex = previousLast >= 0
                ? previousLast
                : root.sectionFloor(root.focusSection)
            return
        }
        root.focusSection = "header"
        root.selectedIndex = -1
    }

    // Tab jumps a whole section instead of walking row by row.
    function moveSection(delta) {
        const sections = root.visibleSections
        let current = sections.indexOf(root.focusSection)
        if (current < 0)
            current = delta > 0 ? -1 : 0
        const next = (current + delta + sections.length) % sections.length
        root.setCursor(sections[next], root.sectionFloor(sections[next]))
    }

    // Adjusts whatever the cursor is on. Device rows are discrete choices, so
    // h/l is a no-op there rather than quietly moving the global slider.
    function adjustVolume(delta) {
        if (root.focusSection === "output" && root.selectedIndex === -1) {
            root.setOutputVolume(root.outputVolume + delta)
            return
        }
        if (root.focusSection === "input" && root.selectedIndex === -1) {
            root.setInputVolume(root.inputVolume + delta)
            return
        }
        // Stream nodes come and go while the panel is open and their ids get
        // recycled, so streams keep their direct QML writes rather than racing
        // a process spawn with the node disappearing.
        if (root.focusSection === "streams" && root.selectedIndex >= 0) {
            const node = root.displayAudioStreams[root.selectedIndex]
            if (node && node.audio)
                node.audio.volume = Math.max(0, Math.min(1.5, node.audio.volume + delta))
        }
    }

    function activateCursor() {
        if (root.focusSection === "header") {
            root.toggleAllMuted()
            return
        }
        if (root.focusSection === "output") {
            if (root.selectedIndex === -1) {
                root.toggleOutputMute()
                return
            }
            root.setDefaultSink(root.displayAudioSinks[root.selectedIndex])
            return
        }
        if (root.focusSection === "input") {
            if (root.selectedIndex === -1) {
                root.toggleInputMute()
                return
            }
            root.setDefaultSource(root.displayAudioSources[root.selectedIndex])
            return
        }
        if (root.focusSection === "streams" && root.selectedIndex >= 0)
            root.toggleStreamMute(root.displayAudioStreams[root.selectedIndex])
    }

    function toggleMuteFocused() {
        if (root.focusSection === "header") {
            root.toggleAllMuted()
            return
        }
        if (root.focusSection === "input") {
            root.toggleInputMute()
            return
        }
        if (root.focusSection === "streams" && root.selectedIndex >= 0) {
            root.toggleStreamMute(root.displayAudioStreams[root.selectedIndex])
            return
        }
        root.toggleOutputMute()
    }

    function clampCursor() {
        // "header" is virtual and never in visibleSections, so it has to be let
        // through: muting republishes the PipeWire snapshot, and clamping would
        // knock the cursor off the hero switch on every toggle.
        if (root.focusSection === "header")
            return
        const sections = root.visibleSections
        if (sections.indexOf(root.focusSection) < 0) {
            root.focusSection = sections[0]
            root.selectedIndex = root.sectionFloor(root.focusSection)
            return
        }
        const floor = root.sectionFloor(root.focusSection)
        const last = root.sectionCount(root.focusSection) - 1
        if (root.selectedIndex > last)
            root.selectedIndex = Math.max(floor, last)
        if (root.selectedIndex < floor)
            root.selectedIndex = floor
    }

    // Keep the focused row inside the panel's visible area. A multi-section
    // Column has no positionViewAtIndex, so the rows ask for this as they gain
    // the cursor.
    function ensureCursorVisible(item) {
        const flick = root.scroller
        if (!item || !flick || flick.contentY === undefined)
            return

        const margin = 6
        const maxY = Math.max(0, (flick.contentHeight || 0) - flick.height)
        const point = item.mapToItem(flick, 0, 0)
        const top = point.y
        const bottom = top + (item.height || 0)
        if (top < flick.contentY + margin)
            flick.contentY = Math.max(0, Math.min(maxY, top - margin))
        else if (bottom > flick.contentY + flick.height - margin)
            flick.contentY = Math.max(0, Math.min(maxY, bottom + margin - flick.height))
    }

    onOpenChanged: {
        if (open) {
            root.focusSection = "output"
            root.selectedIndex = -1  // the first keypress reveals the cursor here
            root.cursorActive = false
            root.resolveVolumeSink()
            Qt.callLater(() => root.refreshDisplayModels())
        } else {
            root.clearDisplayModels()
        }
    }

    PwObjectTracker {
        objects: root.open ? root.candidateSinks : []
    }

    PwObjectTracker {
        objects: root.open ? root.candidateSources : []
    }

    PwObjectTracker {
        objects: root.open ? root.candidateStreams : []
    }

    PwNodePeakMonitor {
        id: inputPeakMonitor

        node: root.source
        enabled: root.open && root.hasInput
    }

    readonly property real inputPeak: inputPeakMonitor.peak

    Process {
        id: outputSinkProc

        command: [root.backend, "output-sink"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.volumeSinkName = String(text).trim()
        }
    }

    Timer {
        id: displayRefreshTimer

        interval: 75
        repeat: false
        onTriggered: root.refreshDisplayModels()
    }

    // Runs closed too: the bar shows the output volume, and an unresolved sink
    // there would read and change the virtual tuning sink instead of speakers.
    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.resolveVolumeSink()
    }

    Component.onCompleted: {
        root.resolveVolumeSink()
        root.refreshDisplayModels()
    }

    IpcHandler {
        target: "audio"

        function toggle(): void { root.toggle() }
        function open(): void { root.open = true }
        function close(): void { root.close() }
    }

    AudioWindow {
        audio: root
        open: root.open
    }
}
