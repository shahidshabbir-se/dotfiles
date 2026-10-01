pragma Singleton

import QtQuick

// Pure naming/glyph logic for the audio panel: everything that turns a
// PipeWire node or an MPRIS player into something a human reads. No state, no
// PipeWire access beyond the node handles it is handed.
QtObject {

    // ---------- Node classification ----------

    // Playback streams publish as sinks (clients connect to their input) while
    // capture streams publish as sources, so the flag alone separates them. This
    // deliberately avoids node.properties: a PwNode's property map is invalid
    // until the node is bound, and reading it while capture streams appear (a
    // recorder starting, say) destabilises Quickshell's PipeWire service.
    function isPlaybackStream(node) {
        return !!(node && node.isStream && node.isSink)
    }

    function isAudioSource(node) {
        return !!(node && node.audio)
    }

    // Flat copy so Repeaters never iterate the live PipeWire model. Nodes can be
    // removed while Quickshell is dispatching that removal; rebuilding a Repeater
    // from the removal signal path has crashed the PipeWire service before.
    function listSnapshot(list) {
        const out = []
        const items = Array.isArray(list) ? list : []
        for (let i = 0; i < items.length; i++) {
            if (items[i])
                out.push(items[i])
        }
        return out
    }

    // ---------- Volume mood ladder ----------

    // Playful band name for a level. Bands are wide on purpose: small tweaks
    // should not rename the room you are in.
    function outputVolumeName(volume, muted) {
        if (muted)
            return "Silenced"
        const v = Math.max(0, Math.min(1, Number(volume) || 0))
        if (v <= 0)
            return "Silent"
        if (v < 0.15)
            return "Whisper"
        if (v < 0.35)
            return "Whispered"
        if (v < 0.6)
            return "Conversational"
        if (v < 0.8)
            return "Energised"
        if (v < 0.95)
            return "Lively"
        return "Raging"
    }

    // ---------- Device labels ----------

    // ALSA and Bluetooth hand out node names, not product names. Pull the parts
    // a person recognises out of them.
    function friendlyDeviceLabel(text) {
        let label = String(text || "")
        if (label.length === 0)
            return "Audio device"

        label = label
            .replace(/^alsa_output\./, "")
            .replace(/^alsa_input\./, "")
            .replace(/^bluez_output\./, "")
            .replace(/^bluez_input\./, "")
            .replace(/\.(sink|source|monitor|mode)$/, "")
            .replace(/_[0-9A-Fa-f]{2}(_[0-9A-Fa-f]{2})*$/, "")
            .replace(/_/g, " ")
            .trim()

        // Drop driver leftovers: "pcm-", "hw", "pro", "default".
        const words = label.split(" ").filter(word => {
            const w = word.toLowerCase()
            return w.length > 0 && w !== "hw" && w !== "pro" && w !== "default" && w !== "pcm"
        })

        if (words.length === 0)
            return "Audio device"
        return words[0].charAt(0).toUpperCase() + words[0].slice(1) + " " + words.slice(1).join(" ")
    }

    // node.name is the PipeWire identifier ("alsa_output.pcm-..."), not
    // something a person would call a device. description/nickname are the
    // product strings, and reading them avoids the node's property map.
    function nodeLabel(node) {
        if (!node)
            return "Unknown device"

        const description = node.description || node.nickname
        if (description && String(description).length > 0)
            return String(description)

        return friendlyDeviceLabel(node.name)
    }

    function isHeadphones(node) {
        if (!node)
            return false
        const haystack = [
            String(node.description || ""),
            String(node.nickname || ""),
            String(node.name || "")
        ].join(" ").toLowerCase()
        return haystack.indexOf("headphone") >= 0
            || haystack.indexOf("headset") >= 0
            || haystack.indexOf("earphone") >= 0
            || haystack.indexOf("earbud") >= 0
            || haystack.indexOf("airpods") >= 0
    }

    function sinkGlyph(node) {
        if (isHeadphones(node))
            return "󰋋"
        const label = nodeLabel(node).toLowerCase()
        if (label.indexOf("hdmi") >= 0 || label.indexOf("display") >= 0
                || label.indexOf("digital") >= 0)
            return "󰍹"
        if (label.indexOf("bluetooth") >= 0)
            return "󰂯"
        return "󰓃"
    }

    function sourceGlyph(node) {
        const label = nodeLabel(node).toLowerCase()
        if (label.indexOf("bluetooth") >= 0)
            return "󰂯"
        return "󰍬"
    }

    // ---------- Stream labels ----------

    function rawStreamLabel(node) {
        return node ? String(node.name || "") : ""
    }

    // Names PipeWire hands out when the client told it nothing useful. They carry
    // no app identity, so they are the ones MPRIS gets asked to fill in.
    function streamLabelIsGeneric(label) {
        const raw = String(label || "")
        if (raw.length === 0)
            return true
        return /^audio-src$/.test(raw)
            || /^pw-stream-/.test(raw)
            || /_input_/.test(raw)
            || /^alsa_(output|input)\.pcm-/.test(raw)
            || /^node\.default$/.test(raw)
    }

    function streamLabelKey(label) {
        return String(label || "")
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, "")
    }

    function friendlyStreamLabel(label) {
        let text = String(label || "")
        text = text
            .replace(/^sink_input_/, "")
            .replace(/^source_output_/, "")
            .replace(/^alsa_output\./, "")
            .replace(/^pw-stream-/, "")
            .replace(/\.(sink|source)$/, "")
            .replace(/_/g, " ")
            .trim()
        if (text.length === 0)
            return "Audio"
        return text.charAt(0).toUpperCase() + text.slice(1)
    }

    // ---------- MPRIS ----------

    function mprisPlayerLabel(player) {
        if (!player)
            return ""
        let identity = String(player.identity || "")
        identity = identity.replace(/\.desktop$/, "")
        const tail = identity.split(".").pop() || identity
        if (tail.length === 0)
            return identity
        return tail.charAt(0).toUpperCase() + tail.slice(1)
    }

    // A stream named after the app it belongs to ("spotify") belongs to that
    // player; "audio-src" belongs to whichever player nothing else claims.
    function mprisPlayerForStreamLabel(label, players) {
        const key = streamLabelKey(label)
        if (key.length < 3)
            return null
        const list = Array.isArray(players) ? players : []
        for (let i = 0; i < list.length; i++) {
            const player = list[i]
            if (!player)
                continue
            const playerKey = streamLabelKey(mprisPlayerLabel(player))
            if (playerKey.length >= 3 && playerKey.indexOf(key) >= 0)
                return player
        }
        return null
    }

    function unmatchedMprisStreamLabel(label, players, streams) {
        const list = Array.isArray(players) ? players : []
        const streamList = Array.isArray(streams) ? streams : []

        for (let i = 0; i < list.length; i++) {
            const player = list[i]
            if (!player)
                continue
            let claimed = false
            for (let j = 0; j < streamList.length; j++) {
                const node = streamList[j]
                if (!node)
                    continue
                const raw = rawStreamLabel(node)
                if (streamLabelIsGeneric(raw))
                    continue
                if (mprisPlayerForStreamLabel(raw, [player])) {
                    claimed = true
                    break
                }
            }
            if (!claimed)
                return mprisPlayerLabel(player)
        }
        return ""
    }

    function streamLabel(node, players, streams) {
        const raw = rawStreamLabel(node)
        if (streamLabelIsGeneric(raw)) {
            const named = mprisPlayerForStreamLabel(raw, players)
            if (named)
                return mprisPlayerLabel(named)
            const unmatched = unmatchedMprisStreamLabel(raw, players, streams)
            if (unmatched.length > 0)
                return unmatched
            return "Audio"
        }
        return friendlyStreamLabel(raw)
    }

    function streamRepresentsPlayer(node, player, players, streams) {
        if (!player)
            return false
        return streamLabel(node, players, streams) === mprisPlayerLabel(player)
    }
}
