// Pure notification history state. Kept free of Qt/Quickshell imports so the
// same functions can be exercised by node in tests/. The QML singleton only
// wraps this state and reassigns it so bindings observe each change.

var MAX_HISTORY = 100;

function initialState() {
    return {
        history: [],
        unread: 0,
        dnd: false,
        centerOpen: false,
        nextId: 1
    };
}

function cleanLine(value, maximum) {
    return String(value === undefined || value === null ? "" : value)
        .replace(/[\u0000-\u001f\u007f]/g, " ")
        .trim()
        .slice(0, maximum);
}

function cleanBody(value) {
    return String(value === undefined || value === null ? "" : value)
        .replace(/\r\n?/g, "\n")
        .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, " ")
        .slice(0, 4096)
        .trim();
}

function makeEntry(data, id, now) {
    var source = data || {};
    var timestamp = Number(now);
    if (!(timestamp > 0))
        timestamp = 0;

    return {
        id: id,
        appName: cleanLine(source.appName, 128),
        summary: cleanLine(source.summary, 512),
        body: cleanBody(source.body),
        appIcon: cleanLine(source.appIcon, 128),
        image: cleanLine(source.image, 1024),
        urgency: cleanLine(source.urgency, 16),
        timestamp: timestamp
    };
}

function copy(history, unread, dnd, centerOpen, nextId) {
    return {
        history: history,
        unread: unread,
        dnd: dnd,
        centerOpen: centerOpen,
        nextId: nextId
    };
}

// New notifications go to the front. If the center is already open the user
// is looking at the entry, so it does not become unread.
function record(state, data, now, maximum) {
    var limit = Number(maximum) > 0 ? Number(maximum) : MAX_HISTORY;
    var entry = makeEntry(data, "n" + state.nextId, now);
    var unread = state.centerOpen ? state.unread : state.unread + 1;

    return copy(
        [entry].concat(state.history).slice(0, limit),
        unread,
        state.dnd,
        state.centerOpen,
        state.nextId + 1
    );
}

function remove(state, id) {
    var history = state.history.filter(function (entry) {
        return entry.id !== id;
    });
    return copy(history, state.unread, state.dnd, state.centerOpen, state.nextId);
}

function clear(state) {
    return copy([], 0, state.dnd, state.centerOpen, state.nextId);
}

function openCenter(state) {
    return copy(state.history, 0, state.dnd, true, state.nextId);
}

function closeCenter(state) {
    return copy(state.history, state.unread, state.dnd, false, state.nextId);
}

function toggleCenter(state) {
    return state.centerOpen ? closeCenter(state) : openCenter(state);
}

function toggleDnd(state) {
    return copy(state.history, state.unread, !state.dnd, state.centerOpen, state.nextId);
}
