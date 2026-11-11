import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { test } from "node:test";
import vm from "node:vm";

const source = readFileSync(
    new URL("../../../legacy/independent-shell/plugins/notifications/History.js", import.meta.url),
    "utf8"
);
const context = {};
vm.createContext(context);
vm.runInContext(source, context);

test("initial state is empty, unread, and not disturbing", () => {
    const state = context.initialState();
    assert.deepEqual(Array.from(state.history), []);
    assert.equal(state.unread, 0);
    assert.equal(state.dnd, false);
    assert.equal(state.centerOpen, false);
});

test("record prepends entries, numbers ids, and increments unread", () => {
    let state = context.initialState();
    state = context.record(state, { appName: "App A", summary: "First" }, 1000);
    state = context.record(state, { appName: "App B", summary: "Second" }, 2000);

    assert.deepEqual(
        Array.from(state.history, entry => entry.id),
        ["n2", "n1"]
    );
    assert.deepEqual(Array.from(state.history, entry => entry.summary), ["Second", "First"]);
    assert.equal(state.unread, 2);
    assert.equal(state.history[0].timestamp, 2000);
});

test("record caps history and drops the oldest entry", () => {
    let state = context.initialState();
    state = context.record(state, { summary: "one" }, 1, 2);
    state = context.record(state, { summary: "two" }, 2, 2);
    state = context.record(state, { summary: "three" }, 3, 2);

    assert.deepEqual(Array.from(state.history, entry => entry.summary), ["three", "two"]);
    assert.equal(state.unread, 3);
});

test("record while the center is open does not create unread state", () => {
    let state = context.openCenter(context.initialState());
    state = context.record(state, { summary: "visible now" }, 10);

    assert.equal(state.centerOpen, true);
    assert.equal(state.unread, 0);
    assert.equal(state.history.length, 1);
});

test("remove deletes one entry without changing unread", () => {
    let state = context.record(context.initialState(), { summary: "keep" }, 1);
    state = context.record(state, { summary: "drop" }, 2);

    const droppedId = state.history[0].id;
    state = context.remove(state, droppedId);

    assert.deepEqual(Array.from(state.history, entry => entry.summary), ["keep"]);
    assert.equal(state.unread, 2);
});

test("clear empties history and unread but keeps DND", () => {
    let state = context.record(context.initialState(), { summary: "gone" }, 1);
    state = context.toggleDnd(state);
    state = context.clear(state);

    assert.equal(state.history.length, 0);
    assert.equal(state.unread, 0);
    assert.equal(state.dnd, true);
});

test("opening the center clears unread; closing it keeps the history", () => {
    let state = context.record(context.initialState(), { summary: "unread" }, 1);
    assert.equal(state.unread, 1);

    state = context.openCenter(state);
    assert.equal(state.centerOpen, true);
    assert.equal(state.unread, 0);
    assert.equal(state.history.length, 1);

    state = context.closeCenter(state);
    assert.equal(state.centerOpen, false);
    assert.equal(state.unread, 0);
    assert.equal(state.history.length, 1);
});

test("toggleCenter opens when closed and closes when open", () => {
    let state = context.initialState();
    state = context.toggleCenter(state);
    assert.equal(state.centerOpen, true);

    state = context.toggleCenter(state);
    assert.equal(state.centerOpen, false);
});

test("toggleDnd keeps history and unread and flips back", () => {
    let state = context.record(context.initialState(), { summary: "quiet" }, 1);
    state = context.toggleDnd(state);

    assert.equal(state.dnd, true);
    assert.equal(state.unread, 1);
    assert.equal(state.history.length, 1);

    state = context.toggleDnd(state);
    assert.equal(state.dnd, false);
});

test("record sanitizes text fields before storing them", () => {
    let state = context.record(context.initialState(), {
        appName: " App\u0000Name ",
        summary: "line\nbreak",
        body: "body\r\ntext",
        appIcon: " icon ",
        image: "/tmp/image.png",
        urgency: 2,
    }, 1);

    assert.equal(state.history[0].appName, "App Name");
    assert.equal(state.history[0].summary, "line break");
    assert.equal(state.history[0].body, "body\ntext");
    assert.equal(state.history[0].appIcon, "icon");
    assert.equal(state.history[0].image, "/tmp/image.png");
    assert.equal(state.history[0].urgency, "2");
});
