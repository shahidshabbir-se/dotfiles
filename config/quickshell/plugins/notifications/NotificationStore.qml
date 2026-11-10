pragma Singleton

import QtQuick
import "History.js" as History

// In-memory notification state shared by the service, the toast stack, the
// center panel, and the bar indicator. Every change replaces `state`, so
// readonly bindings below update without a per-field signal.
QtObject {
    id: root

    property var state: History.initialState()
    property int historyLimit: History.MAX_HISTORY

    readonly property var history: state.history
    readonly property int unread: state.unread
    readonly property bool dnd: state.dnd
    readonly property bool centerOpen: state.centerOpen

    function record(data) {
        state = History.record(state, data || ({}), new Date().getTime(), historyLimit);
    }

    function remove(id) {
        state = History.remove(state, id);
    }

    function clear() {
        state = History.clear(state);
    }

    function openCenter() {
        state = History.openCenter(state);
    }

    function closeCenter() {
        state = History.closeCenter(state);
    }

    function toggleCenter() {
        state = History.toggleCenter(state);
    }

    function toggleDnd() {
        state = History.toggleDnd(state);
    }
}
